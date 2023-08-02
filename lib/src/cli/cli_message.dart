enum CliMessageType { info, success, error }

final class CliMessage {
  final String message;
  final CliMessageType type;
  final int indentationLevel;

  const CliMessage(
    this.message, {
    this.type = CliMessageType.info,
    this.indentationLevel = 0,
  });

  @override
  String toString() {
    const green = '\x1B[32m';
    const red = '\x1B[31m';
    const white = '\x1B[0m';

    final String tabs = '\t' * indentationLevel;

    final String color = switch (type) {
      CliMessageType.success => green,
      CliMessageType.error => red,
      CliMessageType.info => white,
    };

    final String prefix = switch (type) {
      _ when indentationLevel == 0 => '',
      CliMessageType.success => '+ ',
      CliMessageType.error => 'x ',
      CliMessageType.info => '- ',
    };

    return '$tabs$color$prefix$message';
  }
}
