import 'dart:io';

import '../cli_message.dart';
import '../navand_command.dart';

class _File {
  final String _path;
  final String _body;

  const _File({required final String path, required final String body})
      : _path = path,
        _body = body;

  Future<void> _create() async {
    final file = File(_path);

    await file.create(recursive: true);
    await file.writeAsString(_body);
  }
}

class _Dependency {
  final String _name;
  final bool _dev;

  const _Dependency(this._name, {final bool dev = false}) : _dev = dev;

  Future<Process> _install() async {
    return await Process.start(
      'dart',
      [
        'pub',
        'add',
        if (_dev) '-d',
        _name,
      ],
    );
  }
}

final class CreateCommand extends NavandCommand {
  final _dependencies = const {
    _Dependency('navand'),
  };

  final _devDependencies = const {
    _Dependency('lints', dev: true),
    _Dependency('build_runner', dev: true),
    _Dependency('build_web_compilers', dev: true),
  };

  late final _files = {
    const _File(
      path: './.gitignore',
      body: '''
.dart_tool/
build/
''',
    ),
    _File(
      path: './README.md',
      body: '''
# $_appName

A [Navand](https://pub.dev/documentation/navand) App.

## Serve Your App

```
webdev serve
```
''',
    ),
    _File(
      path: './pubspec.yaml',
      body: '''
name: $_appName
description: >
  A Navand app.
publish_to: none
environment:
  sdk: ^3.0.1
''',
    ),
    const _File(
      path: './analysis_options.yaml',
      body: '''
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
''',
    ),
    _File(
      path: './web/index.html',
      body: '''
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
''',
    ),
    _File(
      path: './web/main.dart',
      body: '''
import 'package:navand/navand.dart';
import 'package:$_appName/app.dart';

void main() => runApp(const App());
''',
    ),
    const _File(path: './web/styles.css', body: '''
*,
*::before,
*::after {
  margin: 0px;
  padding: 0px;
  -webkit-tap-highlight-color: transparent;
  box-sizing: border-box;
}
'''),
    const _File(
      path: './lib/app.dart',
      body: '''
import 'package:navand/navand.dart';

import 'widgets/greeting.dart';
import 'widgets/logo.dart';

final class App extends StatelessWidget {
  const App({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const DomWidget(
      'div',
      children: [
        Logo(),
        Greeting(),
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
''',
    ),
    const _File(
      path: './lib/widgets/greeting.dart',
      body: '''
import 'package:navand/navand.dart';

final class Greeting extends StatelessWidget {
  const Greeting({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const Fragment(
      [
        DomWidget(
          'span',
          children: [
            Text('Welcome to Navand!'),
          ],
          style: Style({
            'font-size': '24px',
            'font-weight': 'bold',
            'color': '#00e690',
          }),
        ),
        DomWidget(
          'div',
          children: [
            Text('To get started, edit '),
            DomWidget(
              'span',
              children: [Text('web/main.dart')],
              style: Style({
                'font-family': 'monospace',
                'background': '#212121',
                'border-radius': '4px',
                'padding': '4px',
              }),
            ),
            Text(' and save to reload.'),
          ],
        )
      ],
    );
  }
}
''',
    ),
    const _File(
      path: './lib/widgets/logo.dart',
      body: '''
import 'package:navand/navand.dart';

final class Logo extends StatelessWidget {
  const Logo({super.key, super.ref});

  @override
  Widget build(final BuildContext context) {
    return const DomWidget(
      'img',
      attributes: {
        'src':
            'https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg'
      },
      style: Style({'width': '128px', 'height': '128px'}),
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
''',
    ),
  };

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
        for (final file in _files) {
          await CliMessage(
            'Creating ${file._path}',
            task: () async => await file._create(),
          ).send();
        }
      },
    ).send();
  }

  Future<void> _installDependencies() async {
    await CliMessage(
      'Installing dependencies',
      task: () async {
        for (final dependency in _dependencies) {
          await CliMessage(
            'Installing ${dependency._name}',
            task: () async {
              final process = await dependency._install();

              addProcess(process);

              await process.exitCode;
            },
          ).send();
        }
      },
    ).send();

    await CliMessage(
      'Installing dev dependencies',
      task: () async {
        for (final devDependency in _devDependencies) {
          await CliMessage('Installing ${devDependency._name}', task: () async {
            final process = await devDependency._install();

            addProcess(process);

            await process.exitCode;
          }).send();
        }
      },
    ).send();
  }
}
