// ignore_for_file: avoid_print

final class CliMessage {
  final String message;
  final Future<void> Function()? task;

  const CliMessage(this.message, {this.task});

  Future<void> send() async {
    const red = '\x1B[31m';
    const blue = '\x1B[32m';
    const white = '\x1B[0m';

    if (task == null) {
      print('$white$message');

      return;
    }

    try {
      final stopwatch = Stopwatch()..start();

      await task!();

      stopwatch.stop();

      print(
        '$blue[SUCCESS] $white$message (${stopwatch.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      print('$red[ERROR] $white$message');
    }
  }
}
