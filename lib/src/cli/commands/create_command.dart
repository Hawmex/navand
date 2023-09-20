// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import '../logger.dart';
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
      ['pub', 'add', if (_dev) '-d', _name],
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
  sdk: ^3.1.0
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
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>$_appName</title>

    <link
      rel="shortcut icon"
      href="https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/icon.svg"
      type="image/x-icon"
    />

    <link rel="stylesheet" href="/styles.css" />

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
    const _File(
      path: './web/styles.css',
      body: '''
*,
*::before,
*::after {
  margin: 0px;
  padding: 0px;
  -webkit-tap-highlight-color: transparent;
  box-sizing: border-box;
}
''',
    ),
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
      children: [
        Logo(),
        Greeting(),
      ],
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
          style: Style({
            'font-size': '24px',
            'font-weight': 'bold',
            'color': '#00e690',
          }),
          children: [
            Text('Welcome to Navand!'),
          ],
        ),
        DomWidget(
          'div',
          children: [
            Text('To get started, edit '),
            DomWidget(
              'span',
              style: Style({
                'font-family': 'monospace',
                'background': '#212121',
                'border-radius': '4px',
                'padding': '4px',
              }),
              children: [
                Text('web/main.dart'),
              ],
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

    final regexForAppName = RegExp(r'^([a-z]){1}([a-z]|[0-9]|_){0,}$');

    if (!regexForAppName.hasMatch(_appName)) {
      usageException(
        '<app_name> can only include lowercase letters, digits, and '
        'underscores.\nIt can only start with a lowercase letter.',
      );
    }

    final directory = Directory('./$_appName');

    if (await directory.exists()) {
      usageException('Directory "$_appName" already exists.');
    }

    await logTask(
      task: () async {
        try {
          await _createDirectory(directory);
          await _createFiles();
          await _installDependencies();
        } catch (e, st) {
          Directory.current = Directory.current.parent;
          await directory.delete(recursive: true);
          Error.throwWithStackTrace(e, st);
        }
      },
      message: 'Setting up $_appName',
      source: LogSource.navand,
      showProgress: false,
    );

    print(
      'Run the following commands:\n'
      '\tcd $_appName\n'
      '\twebdev serve',
    );

    exit(0);
  }

  Future<void> _createDirectory(final Directory directory) async {
    await logTask(
      task: () async {
        await directory.create();

        Directory.current = directory;
      },
      message: 'Creating $_appName directory',
      source: LogSource.navand,
    );
  }

  Future<void> _createFiles() async {
    await logTask(
      task: () async {
        for (final file in _files) {
          await logTask(
            task: () async => await file._create(),
            message: 'Creating ${file._path}',
            source: LogSource.navand,
            endWithLineBreak: false,
          );
        }
      },
      message: 'Creating files',
      source: LogSource.navand,
      showProgress: false,
    );
  }

  Future<void> _installDependencies() async {
    await logTask(
      task: () async {
        for (final dependency in _dependencies) {
          await logTask(
            task: () async {
              final process = await dependency._install();

              addProcess(process);

              if (await process.exitCode > 0) {
                throw utf8.decode(await process.stderr.first);
              }
            },
            message: 'Installing ${dependency._name}',
            source: LogSource.pub,
            endWithLineBreak: false,
          );
        }
      },
      message: 'Installing dependencies',
      source: LogSource.navand,
      showProgress: false,
    );

    await logTask(
      task: () async {
        for (final devDependency in _devDependencies) {
          await logTask(
            task: () async {
              final process = await devDependency._install();

              addProcess(process);

              if (await process.exitCode > 0) {
                throw utf8.decode(await process.stderr.first);
              }
            },
            message: 'Installing ${devDependency._name}',
            source: LogSource.pub,
            endWithLineBreak: false,
          );
        }
      },
      message: 'Installing dev dependencies',
      source: LogSource.navand,
      showProgress: false,
    );
  }
}
