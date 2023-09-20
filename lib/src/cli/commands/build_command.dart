// ignore_for_file: avoid_print

import 'dart:io';

import '../logger.dart';
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

    await logTask(
      task: () async {
        final process = await Process.start(
          'dart',
          [
            'run',
            'build_runner',
            'build',
            '-r',
            '-o',
            'web:build',
          ],
          mode: ProcessStartMode.inheritStdio,
        );

        addProcess(process);

        if (await process.exitCode > 0) {
          throw '';
        }
      },
      message: 'Building for production',
      source: LogSource.buildRunner,
    );

    exit(0);
  }
}
