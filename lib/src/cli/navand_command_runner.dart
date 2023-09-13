// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'cli_message.dart';
import 'commands/build_command.dart';
import 'commands/create_command.dart';
import 'commands/serve_command.dart';
import 'package_version.dart';

final class NavandCommandRunner extends CommandRunner<void> {
  NavandCommandRunner()
      : super('navand', 'Manage your Navand app development.') {
    argParser.addFlag(
      'version',
      help: 'Print Navand version.',
      negatable: false,
    );

    addCommand(CreateCommand());
    addCommand(ServeCommand());
    addCommand(BuildCommand());
  }

  @override
  Future<void> run(final Iterable<String> args) async {
    try {
      return await super.run(args);
    } on UsageException catch (e) {
      print('${e.message}\n\n${e.usage}');
      exit(1);
    } catch (e, st) {
      print('$e\n\n$st');
      exit(1);
    }
  }

  @override
  Future<void> runCommand(final ArgResults topLevelResults) async {
    final shouldPrintVersion = topLevelResults['version'] as bool;

    if (shouldPrintVersion) {
      await const CliMessage('Navand version: $packageVersion').send();

      exit(0);
    }

    return await super.runCommand(topLevelResults);
  }
}
