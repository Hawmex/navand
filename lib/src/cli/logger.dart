import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart' as ansi;

enum LogSource {
  navand('NAVAND', ansi.cyan),
  pub('PUB', ansi.magenta),
  buildRunner('BUILD_RUNNER', ansi.yellow);

  final String name;
  final ansi.AnsiCode color;

  const LogSource(this.name, this.color);
}

enum _LogStatus {
  inProgress,
  hasError,
  done,
}

Future<void> logTask({
  required final Future<void> Function() task,
  required final String message,
  required final LogSource source,
  final bool endWithLineBreak = true,
  final bool showProgress = true,
}) async {
  const progressIndicatorFrames = {
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  };

  final stopwatch = Stopwatch();
  final wrappedSource = source.color.wrap('[${source.name}] ');

  String getElapsedTime() {
    final elapsedTime =
        (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1);

    return ansi.darkGray.wrap('(${elapsedTime}s)')!;
  }

  _LogStatus status = _LogStatus.inProgress;

  Object? error;
  StackTrace? stackTrace;

  stdout.write('\u001b[?25l\u001b[2K\r');
  stopwatch.start();

  task().then((final _) {
    stopwatch.stop();
    status = _LogStatus.done;
  }).catchError((final Object? e, final StackTrace st) {
    stopwatch.stop();
    status = _LogStatus.hasError;
    error = e;
    stackTrace = st;
  });

  int progressIndicatorFrameIndex = 0;

  do {
    if (showProgress) {
      final progressIndicatorFrame = progressIndicatorFrames.elementAt(
        progressIndicatorFrameIndex % progressIndicatorFrames.length,
      );

      stdout.writeAll([
        '\r',
        ansi.green.wrap('$progressIndicatorFrame '),
        wrappedSource,
        '$message... ',
        getElapsedTime(),
      ]);

      progressIndicatorFrameIndex++;
    }

    await Future<void>.delayed(const Duration(milliseconds: 80));
  } while (status == _LogStatus.inProgress);

  if (status == _LogStatus.hasError) {
    stdout.writeAll([
      '\u001b[2K\r',
      ansi.red.wrap('x '),
      wrappedSource,
      '$message. ',
      getElapsedTime(),
      '\n',
    ]);

    Error.throwWithStackTrace(error!, stackTrace!);
  }

  if (status == _LogStatus.done) {
    stdout.writeAll([
      '\u001b[2K\r',
      ansi.green.wrap('✓ '),
      wrappedSource,
      '$message. ',
      getElapsedTime(),
      if (endWithLineBreak) '\n',
    ]);
  }
}
