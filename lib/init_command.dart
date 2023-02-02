import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:mppm/util.dart';
import 'package:mppm/yaml_parser.dart';

class InitCommand extends Command {
  final YamlParser _yamlParser;

  InitCommand(this._yamlParser);

  @override
  String get description => 'Prepare your project to use mppm';

  @override
  String get name => 'init';

  @override
  Future<void> run() async {
    if (!isDartProject()) {
      printerr(red('Execute this command from the root of the project'));
      exit(2);
    }

    if (!exists(mppmFilePath)) {
      touch(mppmFilePath, create: true);
      _yamlParser.writeContent();
    } else {
      _yamlParser.updateContent();
    }
  }
}
