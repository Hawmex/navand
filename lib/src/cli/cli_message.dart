// ignore_for_file: avoid_print

enum CliMessageType { info, error, normal }

final class CliMessage {
  final String message;
  final int indentationLevel;
  final void Function()? task;
  final CliMessageType type;

  const CliMessage.info(
    this.message, {
    this.indentationLevel = 0,
    this.task,
  }) : type = CliMessageType.info;

  const CliMessage.error(
    this.message, {
    this.indentationLevel = 0,
    this.task,
  }) : type = CliMessageType.error;

  const CliMessage.normal(
    this.message, {
    this.indentationLevel = 0,
    this.task,
  }) : type = CliMessageType.normal;

  String get _output {
    const red = '\x1B[31m';
    const blue = '\x1B[36m';
    const white = '\x1B[0m';

    final tabs = '\t' * indentationLevel;

    final prefix = switch (type) {
      CliMessageType.info => '$blue[INFO] ',
      CliMessageType.error => '$red[ERROR] ',
      CliMessageType.normal => '',
    };

    return '$tabs$prefix$white$message';
  }

  void run() {
    if (task == null) {
      print(_output);
      return;
    }

    final stopwatch = Stopwatch()..start();

    task!();

    stopwatch.stop();

    print('$_output (${stopwatch.elapsedMilliseconds}ms)');
  }
}
