import 'dart:io';

import 'package:args/command_runner.dart';

abstract base class NavandCommand extends Command<void> {
  final _activeProcesses = <Process>{};

  @override
  void run() {
    ProcessSignal.sigint.watch().listen((final signal) => shutDown());
  }

  void addProcess(final Process process) {
    _activeProcesses.add(process);
  }

  void shutDown() {
    for (final process in _activeProcesses) {
      process.kill();
    }

    exit(1);
  }
}
