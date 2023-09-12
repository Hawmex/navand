import 'dart:io';

import '../cli_message.dart';
import '../navand_command.dart';

final class BuildCommand extends NavandCommand {
  @override
  String get name => 'build';

  @override
  String get description => 'Compile your project for production use.';

  @override
  String get invocation => 'navand build';

  @override
  Future<void> run() async {
    super.run();

    await const CliMessage('Starting build_runner.').send();

    try {
      final process = await Process.start(
        'dart',
        ['run', 'build_runner', 'build', '-r', '-o', 'web:build'],
        mode: ProcessStartMode.inheritStdio,
      );

      addProcess(process);

      await process.exitCode;

      exit(exitCode);

      // ignore: empty_catches
    } catch (e) {}
  }
}
