import 'package:args/command_runner.dart';
import 'package:mppm/init_command.dart';

void main(List<String> args) async {
  final runner =
      CommandRunner('mppm', 'manage plugins in a multiple package project')
        ..addCommand(InitCommand());

  await runner.run(args);
}
