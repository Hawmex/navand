// ignore_for_file: avoid_print

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../core/package_version.dart';
import 'cli_message.dart';

final class NavandCommandRunner extends CommandRunner<int> {
  NavandCommandRunner()
      : super('navand', 'Manage your Navand app development.') {
    argParser.addFlag(
      'version',
      help: 'Print Navand version.',
      negatable: false,
    );
  }

  @override
  Future<int?> run(final Iterable<String> args) async {
    try {
      await super.run(args);

      return 0;
    } on UsageException catch (e) {
      print('${e.message}\n${e.usage}');

      return 1;
    } catch (e, st) {
      print('$e\n$st');

      return 1;
    }
  }

  @override
  Future<int?> runCommand(final ArgResults topLevelResults) async {
    final shouldPrintVersion = topLevelResults['version'] as bool;

    if (shouldPrintVersion) {
      print(const CliMessage('Navand version: $packageVersion'));

      return 0;
    }

    return super.runCommand(topLevelResults);
  }
}
