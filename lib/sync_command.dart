import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:file/file.dart';
import 'package:mppm/util.dart';
import 'package:mppm/yaml_parser.dart';
import 'package:yaml_modify/yaml_modify.dart';

class SyncCommand extends Command {
  final YamlParser _yamlParser;

  SyncCommand(this._yamlParser);

  @override
  String get description => 'Sync all the dependencies across packages';

  @override
  String get name => 'sync';

  @override
  void run() {
    if (!isDartProject()) {
      printerr(red('Execute this command from the root of the project'));
      io.exit(2);
    }
    if (!_yamlParser.isSourceFileValid()) {
      printerr(red('Invalid mppm.yaml'));
      io.exit(2);
    }

    final paths = _yamlParser.getDirectoriesPath();
    if (paths.isEmpty) {
      printerr(
        red('Invalid package path. Please check the glob pattern under packages section in mppm.yaml'),
      );
      io.exit(2);
    }
    for (final dartPackageDir in paths) {
      _updatePackagePubspec(dartPackageDir);
    }
  }

  /*
   * TODO: Need to figure out a way to add local deps with correct relative path
   */
  void _updatePackagePubspec(FileSystemEntity dartPackageDir) {
    final pubspecPath = join(dartPackageDir.path, 'pubspec.yaml');
    final pubspecContent = _pubspecContent(pubspecPath);
    final existingDependencies = pubspecContent['dependencies'] as YamlMap;
    final existingDevDependencies =
        pubspecContent['dev_dependencies'] as YamlMap;

    final mppmContent = _mppmContent();
    final mppmCommonDependencies =
        mppmContent['common_dependencies'] as YamlMap;
    final mppmCommonDevDependencies =
        mppmContent['common_dev_dependencies'] as YamlMap;

    final newDependencies = {};
    mppmCommonDependencies.forEach((key, value) {
      if (!existingDependencies.containsKey(key)) {
        newDependencies[key] = value;
      }
    });

    final newDevDependencies = {};
    mppmCommonDevDependencies.forEach((key, value) {
      if (!existingDevDependencies.containsKey(key)) {
        newDevDependencies[key] = value;
      }
    });

    final modifiablePubspecContent = getModifiableNode(pubspecContent);
    modifiablePubspecContent['dependencies'] = {
      ...existingDependencies,
      ...newDependencies
    };
    modifiablePubspecContent['dev_dependencies'] = {
      ...existingDevDependencies,
      ...newDevDependencies,
    };
    final strYaml = toYamlString(modifiablePubspecContent);
    _yamlParser.writeToFile(filePath: pubspecPath, content: strYaml);
  }

  dynamic _mppmContent() {
    final mppm = _yamlParser.readYamlFile(mppmFilePath);
    final mppmContent = _yamlParser.parseYamlContent(mppm);
    return mppmContent;
  }

  dynamic _pubspecContent(String pubspecPath) {
    final pubspec = _yamlParser.readYamlFile(pubspecPath);
    final pubspecContent = _yamlParser.parseYamlContent(pubspec);
    return pubspecContent;
  }
}
