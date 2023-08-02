// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/command_runner.dart';

import '../cli_message.dart';
import '../process_runner.dart';

final class CreateCommand extends Command<int> {
  @override
  String get name => 'create';

  @override
  String get description => 'Set up a new Navand project.';

  @override
  String get invocation => 'navand create <app_name>';

  String get _appName => argResults!.rest.first;

  @override
  int? run() {
    if (argResults!.rest.isEmpty) {
      usageException('Please specify <app_name>.');
    }

    final directory = Directory('./$_appName');

    if (directory.existsSync()) {
      usageException('Directory "$_appName" already exists.');
    }

    Directory.current = directory..createSync();

    print(CliMessage('Setting up $_appName...'));

    _createFiles();
    _installDependencies();

    print(
      CliMessage(
        '\nSuccessfully set up $_appName.',
        type: CliMessageType.success,
      ),
    );

    print(const CliMessage('\nEnjoy coding!'));

    print(
      CliMessage(
        '\nRun the following commands:\n'
        '\tcd $_appName\n'
        '\twebdev serve',
      ),
    );

    return 0;
  }

  void _createFiles() {
    print(const CliMessage('\nCreating files...'));

    _createFile(path: './.gitignore', contents: _gitIgnore);
    _createFile(path: './README.md', contents: _readmeDotMd);
    _createFile(path: './pubspec.yaml', contents: _pubspecDotYaml);

    _createFile(
      path: './analysis_options.yaml',
      contents: _analysisOptionsDotYaml,
    );

    _createFile(path: './web/index.html', contents: _indexDotHtml);
    _createFile(path: './web/main.dart', contents: _mainDotDart);
  }

  void _createFile({
    required final String path,
    required final String contents,
  }) {
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);

    print(
      CliMessage(
        'Created $path.',
        indentationLevel: 1,
        type: CliMessageType.success,
      ),
    );
  }

  void _installDependencies() {
    print(const CliMessage('\nInstalling dependencies...'));

    _installDependency('navand');

    print(const CliMessage('\nInstalling dev dependencies...'));

    _installDependency('lints', dev: true);
    _installDependency('build_runner', dev: true);
    _installDependency('build_web_compilers', dev: true);
  }

  void _installDependency(final String name, {final bool dev = false}) {
    runProcess(
      'dart',
      ['pub', 'add', if (dev) '-d', name],
      throwOnError: false,
      onSuccess: () => print(
        CliMessage(
          'Successfully installed $name.',
          indentationLevel: 1,
          type: CliMessageType.success,
        ),
      ),
      onError: () => print(
        CliMessage(
          'Failed to install $name.',
          indentationLevel: 1,
          type: CliMessageType.error,
        ),
      ),
    );
  }

  String get _gitIgnore => '''
.dart_tool/
build/
''';

  String get _readmeDotMd => '''
# $_appName

A [Navand](https://pub.dev/documentation/navand) App.

## Serve Your App

```
webdev serve
```
''';

  String get _pubspecDotYaml => '''
name: $_appName
description: >
  A Navand app.
publish_to: none
environment:
  sdk: ^3.0.1
''';

  String get _analysisOptionsDotYaml => '''
include: package:lints/recommended.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_locals: true
    prefer_final_in_for_each: true
    prefer_final_parameters: true
    prefer_relative_imports: true
    avoid_print: true
    comment_references: true

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
''';

  String get _indexDotHtml => '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>$_appName</title>

    <link
      rel="shortcut icon"
      href="https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg"
      type="image/x-icon"
    />

    <style>
      *,
      *::before,
      *::after {
        margin: 0px;
        padding: 0px;
        -webkit-tap-highlight-color: transparent;
        box-sizing: border-box;
      }
    </style>

    <script src="/main.dart.js" defer></script>
  </head>

  <body>
    <noscript>You need to enable JavaScript to run this app!</noscript>
  </body>
</html>
''';

  String get _mainDotDart => '''
import 'package:navand/navand.dart';

void main() => runApp(const App());

final class App extends StatelessWidget {
  const App({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const Container(
      [
        Image(
          'https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg',
          style: Style({'width': '128px', 'height': '128px'}),
          animation: Animation(
            keyframes: [
              Keyframe(
                offset: 0,
                style: Style({'transform': 'translateY(0px)'}),
              ),
              Keyframe(
                offset: 1,
                style: Style({'transform': 'translateY(8px)'}),
              ),
            ],
            duration: Duration(seconds: 1),
            easing: Easing(0.2, 0, 0.4, 1),
            direction: AnimationDirection.alternate,
            iterations: double.infinity,
          ),
        ),
        Text(
          'Welcome to Navand!',
          style: Style({
            'font-size': '24px',
            'font-weight': 'bold',
            'color': '#00e690',
          }),
        ),
        Container([
          Text('To get started, edit '),
          Text(
            'web/main.dart',
            style: Style({
              'font-family': 'monospace',
              'background': '#212121',
              'border-radius': '4px',
              'padding': '4px',
            }),
          ),
          Text(' and save to reload.'),
        ]),
      ],
      style: Style({
        'display': 'flex',
        'flex-flow': 'column',
        'justify-content': 'center',
        'text-align': 'center',
        'align-items': 'center',
        'gap': '16px',
        'padding': '16px',
        'width': '100%',
        'min-height': '100vh',
        'background': '#0d1117',
        'color': '#ffffff',
        'font-family': 'system-ui',
        'user-select': 'none',
      }),
    );
  }
}
''';
}
