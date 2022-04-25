import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:mppm/util.dart';
import 'package:yaml/yaml.dart';

class InitCommand extends Command {
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

    if (!exists('mppm.yaml')) {
      touch('mppm.yaml', create: true);
      _writeContent();
    } else {
      _updateContent();
    }
  }
}

//Write the template to yaml file
void _writeContent() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final name = loadYaml(pubspec)['name'];
  'mppm.yaml'.write(mppmTemplate(name));
}

//Overwrite the existing yaml file if user re-execute the init command.
//Before overwriting the user will be asked for a confirmation.
void _updateContent() {
  if (exists('mppm.yaml') &&
      confirm(
          'Warning: mppm.yaml will be overwritten. Do you wanna proceed?')) {
    delete('mppm.yaml');
  }
  _writeContent();
}
