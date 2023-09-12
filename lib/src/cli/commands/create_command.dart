import 'dart:io';

import '../cli_message.dart';
import '../navand_command.dart';

final class CreateCommand extends NavandCommand {
  @override
  String get name => 'create';

  @override
  String get description => 'Set up a new project.';

  @override
  String get invocation => 'navand create <app_name>';

  String get _appName => argResults!.rest.first;

  @override
  Future<void> run() async {
    super.run();

    if (argResults!.rest.isEmpty) {
      usageException('Please specify <app_name>.');
    }

    final directory = Directory('./$_appName');

    if (await directory.exists()) {
      usageException('Directory "$_appName" already exists.');
    }

    await CliMessage(
      'Setting up $_appName',
      task: () async {
        await directory.create();

        Directory.current = directory;

        await _createFiles();
        await _installDependencies();
      },
    ).send();

    await CliMessage(
      'Run the following commands:\n'
      '\tcd $_appName\n'
      '\twebdev serve',
    ).send();

    exit(0);
  }

  Future<void> _createFiles() async {
    await CliMessage(
      'Creating files',
      task: () async {
        await _createFile(path: './.gitignore', contents: _gitIgnore);
        await _createFile(path: './README.md', contents: _readmeDotMd);
        await _createFile(path: './pubspec.yaml', contents: _pubspecDotYaml);

        await _createFile(
          path: './analysis_options.yaml',
          contents: _analysisOptionsDotYaml,
        );

        await _createFile(path: './web/index.html', contents: _indexDotHtml);
        await _createFile(path: './web/main.dart', contents: _mainDotDart);
      },
    ).send();
  }

  Future<void> _createFile({
    required final String path,
    required final String contents,
  }) async {
    await CliMessage(
      'Creating $path',
      task: () async {
        final file = File(path);

        await file.create(recursive: true);
        await file.writeAsString(contents);
      },
    ).send();
  }

  Future<void> _installDependencies() async {
    await CliMessage(
      'Installing dependencies',
      task: () async => await _installDependency('navand'),
    ).send();

    await CliMessage(
      'Installing dev dependencies',
      task: () async {
        await _installDependency('lints', dev: true);
        await _installDependency('build_runner', dev: true);
        await _installDependency('build_web_compilers', dev: true);
      },
    ).send();
  }

  Future<void> _installDependency(
    final String name, {
    final bool dev = false,
  }) async {
    await CliMessage(
      'Installing $name',
      task: () async {
        final process = await Process.start(
          'dart',
          ['pub', 'add', if (dev) '-d', name],
        );

        addProcess(process);

        await process.exitCode;
      },
    ).send();
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
      /* You can apply global styles here. */

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

// The main widget of your Navand application.
final class App extends StatelessWidget {
  const App({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    // You can use `Container` to wrap multiple widgets.
    return const Container(
      [Logo(), Greeting()],
      // You can use `Style` to style your painted widgets.
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

final class Logo extends StatelessWidget {
  const Logo({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const Image(
      'https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg',
      style: Style({'width': '128px', 'height': '128px'}),
      // You can use `Animation` to add animation to widgets.
      animation: Animation(
        keyframes: [
          Keyframe(offset: 0, style: Style({'transform': 'translateY(0px)'})),
          Keyframe(offset: 1, style: Style({'transform': 'translateY(8px)'})),
        ],
        duration: Duration(seconds: 1),
        easing: Easing(0.2, 0, 0.4, 1),
        direction: AnimationDirection.alternate,
        iterations: double.infinity,
      ),
    );
  }
}

final class Greeting extends StatelessWidget {
  const Greeting({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    // Tip: You can use `'display': 'contents'` with `Container` to render
    // multiple children without a wrapper.
    return const Container(
      [
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
        ])
      ],
      style: Style({'display': 'contents'}),
    );
  }
}
''';
}
