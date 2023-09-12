import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart' as shelf_proxy;

import '../cli_message.dart';
import '../navand_command.dart';

final class ServeCommand extends NavandCommand {
  late final HttpServer _server;

  @override
  String get name => 'serve';

  @override
  String get description => 'Start a development server.';

  @override
  String get invocation => 'navand serve';

  shelf.Handler _proxyRootIndexHandler(final shelf.Handler proxyHandler) {
    return (final shelf.Request req) {
      final indexRequest = shelf.Request(
        'GET',
        req.requestedUri.replace(path: '/'),
        context: req.context,
        encoding: req.encoding,
        headers: req.headers,
        protocolVersion: req.protocolVersion,
      );

      return proxyHandler(indexRequest);
    };
  }

  @override
  Future<void> run() async {
    super.run();

    const hostname = 'localhost';
    const buildRunnerPort = 3000;
    const proxyPort = 3001;

    await const CliMessage(
      'Starting build_runner at http://$hostname:$buildRunnerPort',
    ).send();

    try {
      final process = await Process.start(
        'dart',
        [
          'run',
          'build_runner',
          'serve',
          'web:$buildRunnerPort',
          '--hostname',
          hostname,
        ],
        mode: ProcessStartMode.inheritStdio,
      );

      addProcess(process);

      // ignore: empty_catches
    } catch (e) {}

    await const CliMessage(
      'Starting the proxy server at http://$hostname:$proxyPort',
    ).send();

    final localhostProxyHandler =
        shelf_proxy.proxyHandler('http://$hostname:$buildRunnerPort');

    final cascade = shelf.Cascade()
        .add(localhostProxyHandler)
        .add(_proxyRootIndexHandler(localhostProxyHandler));

    _server = await shelf_io.serve(cascade.handler, hostname, proxyPort);
  }

  @override
  void shutDown() {
    super.shutDown();
    _server.close(force: true);
  }
}
