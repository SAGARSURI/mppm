import 'package:dcli/dcli.dart';
import 'package:file/file.dart';
import 'package:mppm/mppm_template.dart';
import 'package:mppm/util.dart';
import 'package:yaml_modify/yaml_modify.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'glob.dart';

class YamlParser {
  final FileSystem fileSystem;
  final MppmTemplate mppmTemplate;

  YamlParser({
    required this.fileSystem,
    required this.mppmTemplate,
  });

  bool isSourceFileValid() {
    if (!_isSourceFileExists()) {
      return false;
    }
    final mppmContent = parseYamlContent(readYamlFile(mppmFilePath));
    if (mppmContent['packages'] is! YamlList ||
        mppmContent['common_dependencies'] is! YamlMap ||
        mppmContent['common_dev_dependencies'] is! YamlMap) {
      return false;
    }
    return true;
  }

  ///Write the template to yaml file
  void writeContent() {
    final pubspec = readYamlFile(pubspecFileName);
    final name = parseYamlContent(pubspec)['name'];
    final mppmFile = fileSystem.file(mppmFilePath)..createSync();
    final yamlWriter = YAMLWriter();
    final yamlDoc = yamlWriter.write(mppmTemplate.basicTemplate(name));
    mppmFile.writeAsStringSync(yamlDoc);
  }

  ///Overwrite the existing yaml file if user re-execute the init command.
  ///Before overwriting, the user will be asked for a confirmation.
  void updateContent() {
    if (_isSourceFileExists() &&
        confirm(
            'Warning: mppm.yaml will be overwritten. Do you wanna proceed?')) {
      fileSystem.file(mppmFilePath).deleteSync();
    }
    writeContent();
  }

  String readYamlFile(String fileName) {
    return fileSystem.currentDirectory.childFile(fileName).readAsStringSync();
  }

  dynamic parseYamlContent(String content) => loadYaml(content);

  List<FileSystemEntity> getDirectoriesPath() {
    return _packagePaths().map((package) {
      return _getFileSystemEntitiesFromGlob(package);
    }).fold<List<FileSystemEntity>>(
        [], (value, element) => value + element).where((element) {
      final pubspecPath = join(element.path, 'pubspec.yaml');
      final libPath = join(element.path, 'lib');
      return fileSystem.isFileSync(pubspecPath) &&
          fileSystem.isDirectorySync(libPath);
    }).toList();
  }

  void writeToFile({required String filePath, required String content}) {
    fileSystem.currentDirectory.childFile(filePath).writeAsStringSync(content);
  }

  List<String> _packagePaths() {
    final mppmContent = parseYamlContent(readYamlFile(mppmFilePath));
    final packages = mppmContent['packages'];
    if (packages == null || packages is! YamlList) {
      return [];
    }
    final list = mppmContent['packages'] as YamlList;
    return list.map((element) => element.toString()).toList();
  }

  bool _isSourceFileExists() => exists(mppmFilePath);

  List<FileSystemEntity> _getFileSystemEntitiesFromGlob(String package) {
    final glob = createGlob(package,
        caseSensitive: true,
        currentDirectoryPath: fileSystem.currentDirectory.path);
    try {
      return glob.listFileSystemSync(fileSystem);
    } catch (e) {
      return [];
    }
  }
}
