import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mppm/mppm_template.dart';
import 'package:mppm/yaml_parser.dart';
import 'package:spec/spec.dart';

void main() {
  late MockMppmTemplate mockMppmTemplate;
  late MemoryFileSystem memoryFileSystem;
  late YamlParser sut;

  setUp(() {
    mockMppmTemplate = MockMppmTemplate();
    memoryFileSystem = MemoryFileSystem.test();
    sut = YamlParser(
      fileSystem: memoryFileSystem,
      mppmTemplate: mockMppmTemplate,
    );
  });

  File createPubspecFile() {
    return memoryFileSystem.file('pubspec.yaml')..createSync();
  }

  test(
      'isSourceFileValid should return false, if the source file has invalid template',
      () {
    final pubspec = createPubspecFile();
    when(() => mockMppmTemplate.basicTemplate(any()))
        .thenReturn({"name": "name"});
    pubspec.writeAsStringSync("name: name");

    sut.writeContent();

    expect(sut.isSourceFileValid()).isFalse();
  });

  test(
      'isSourceFileValid should return true, if the source file has valid template',
      () {
    final pubspec = createPubspecFile();
    when(() => mockMppmTemplate.basicTemplate(any())).thenReturn({
      "name": "name",
      'packages': ['packages/*'],
      'common_dependencies': {'path': 'any'},
      'common_dev_dependencies': {'mocktail': 'any'}
    });
    pubspec.writeAsStringSync("name: name");

    sut.writeContent();

    expect(sut.isSourceFileValid()).isTrue();
  });

  test(
      'getDirectoriesPath should return list of valid paths, when mppm.yaml has valid dart packages path under packages section',
      () {
    final pubspec = createPubspecFile();
    final packagesDir = memoryFileSystem.directory('packages')..createSync();
    final paymentDir = packagesDir.childDirectory('payment')..createSync();
    final homeDir = packagesDir.childDirectory('home')..createSync();
    paymentDir.childFile('pubspec.yaml').createSync();
    homeDir.childFile('pubspec.yaml').createSync();
    paymentDir.childDirectory('lib').createSync();
    homeDir.childDirectory('lib').createSync();

    when(() => mockMppmTemplate.basicTemplate(any())).thenReturn({
      "name": "name",
      'packages': ['packages/*'],
      'common_dependencies': {'path': 'any'},
      'common_dev_dependencies': {'mocktail': 'any'}
    });
    pubspec.writeAsStringSync("name: name");

    sut.writeContent();

    final actual = sut.getDirectoriesPath();

    expect(actual.isNotEmpty).isTrue();
    expect(actual.length).toEqual(2);
    expect(actual[0].path.contains('payment')).isTrue();
    expect(actual[1].path.contains('home')).isTrue();
  });

  test(
      'getDirectoriesPath should return empty list, when no directory exists as specified in mppm.yaml',
      () {
    final pubspec = createPubspecFile();
    when(() => mockMppmTemplate.basicTemplate(any())).thenReturn({
      "name": "name",
      'packages': ['packages/*'],
      'common_dependencies': {'path': 'any'},
      'common_dev_dependencies': {'mocktail': 'any'}
    });
    pubspec.writeAsStringSync("name: name");
    sut.writeContent();

    final actual = sut.getDirectoriesPath();

    expect(actual.isEmpty).isTrue();
  });

  test(
      'getDirectoriesPath should return empty list, when no valid dart package exists as specified in mppm.yaml',
      () {
    final pubspec = createPubspecFile();
    final packagesDir = memoryFileSystem.directory('packages')..createSync();
    packagesDir.childDirectory('payment').createSync();
    packagesDir.childDirectory('home').createSync();
    when(() => mockMppmTemplate.basicTemplate(any())).thenReturn({
      "name": "name",
      'packages': ['packages/*'],
      'common_dependencies': {'path': 'any'},
      'common_dev_dependencies': {'mocktail': 'any'}
    });
    pubspec.writeAsStringSync("name: name");
    sut.writeContent();

    final actual = sut.getDirectoriesPath();

    expect(actual.isEmpty).isTrue();
  });
}

class MockMppmTemplate extends Mock implements MppmTemplate {}
