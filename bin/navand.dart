import 'package:navand/src/cli/navand_command_runner.dart';

Future<void> main(final List<String> args) async {
  return await NavandCommandRunner().run(args);
}
