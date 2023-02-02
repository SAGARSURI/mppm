import 'package:args/command_runner.dart';
import 'package:file/local.dart';
import 'package:mppm/init_command.dart';
import 'package:mppm/mppm_template.dart';
import 'package:mppm/sync_command.dart';
import 'package:mppm/yaml_parser.dart';

void main(List<String> args) async {
  final yamlParser = YamlParser(
    fileSystem: LocalFileSystem(),
    mppmTemplate: MppmTemplate(),
  );
  final runner =
      CommandRunner('mppm', 'manage plugins in a multiple package project')
        ..addCommand(InitCommand(yamlParser))
        ..addCommand(SyncCommand(yamlParser));

  await runner.run(args);
}
