import 'dart:async';
import 'dart:html' as html;

import '../animation/animation.dart';
import '../core/build_context.dart';
import '../core/style.dart';
import '../widgets/container.dart';
import '../widgets/stateful_widget.dart';
import '../widgets/widget.dart';
import 'route.dart';
import 'route_state.dart';

/// A navigation outlet.
///
/// **Notice:** Only a single instance of [Navigator] should be present in an
/// app.
final class Navigator extends StatefulWidget {
  static _NavigatorState? _state;

  /// Pops all modals and replaces the current route.
  static void replaceRoute(final String path) => _state!._replaceRoute(path);

  /// Pops all modals and pushes a new route.
  static void pushRoute(final String path) => _state!._pushRoute(path);

  /// Pushes a new modal.
  static void pushModal({required final void Function() onPop}) =>
      _state!._pushModal(onPop: onPop);

  /// Pops the latest modal. If no modal is open, the current route is popped.
  static void pop() => _state!._pop();

  final List<Route> routes;

  /// The animation that should be applied to the child after it's been replaced
  /// or pushed.
  final Animation? replaceOrPushAnimation;

  /// The animation that should be applied to the child after the previous one
  /// was popped.
  final Animation? popAnimation;

  /// Creates a new [Navigator].
  const Navigator({
    required this.routes,
    this.replaceOrPushAnimation,
    this.popAnimation,
    super.key,
    super.ref,
  });

  @override
  State createState() => _NavigatorState();
}

final class _RouteEntry {
  final Widget widget;
  final Ref ref;

  late final Widget wrappedWidget = Container(
    [widget],
    ref: ref,
    style: const Style({
      'position': 'absolute',
      'left': '0px',
      'top': '0px',
      'width': '100%',
      'height': '100%',
    }),
  );

  _RouteEntry({required this.widget, required this.ref});
}

final class _NavigatorState extends State<Navigator> {
  static Route? _getMatchingRoute({
    required final Route route,
    required final List<String> segments,
    required final Map<String, String> params,
  }) {
    if (route.variant == RouteVariant.wildcard) return route;

    if (route.variant == RouteVariant.dynamic) {
      params[route.path.substring(1)] = segments.first;
    }

    if (route.variant == RouteVariant.static && route.path != segments.first) {
      return null;
    }

    if (segments.length == 1) return route;

    for (final route in route.routes) {
      final result = _getMatchingRoute(
        route: route,
        segments: [...segments]..removeAt(0),
        params: params,
      );

      if (result != null) return result;
    }

    return null;
  }

  final _modalPoppers = <void Function()>[];
  final _routeEntries = <_RouteEntry>[];

  late final StreamSubscription<html.Event> _historyBackSubscription;

  void _popAllModalPoppers() {
    final n = _modalPoppers.length;

    for (int i = 0; i < n; i++) {
      _pop();
    }
  }

  void _popModalPoppers() => _modalPoppers.removeLast()();

  void _addModalPopper(final void Function() popper) {
    _pushHistory();
    _modalPoppers.add(popper);
  }

  Future<void> _popRouteEntries() async {
    final lastRouteElement = _routeEntries.removeLast().ref.currentElement!;

    await widget.popAnimation?.runOnElement(lastRouteElement).finished;

    setState(() {});
  }

  void _addRouteEntry() {
    _routeEntries.add(_RouteEntry(widget: _build(context), ref: Ref()));

    setState(() {});

    html.window.requestAnimationFrame(
      (final highResTime) => widget.replaceOrPushAnimation?.runOnElement(
        _routeEntries.last.ref.currentElement!,
      ),
    );
  }

  void _replaceHistory(final String path) async {
    if (_routeEntries.isNotEmpty) await _popRouteEntries();

    html.window.history.replaceState(null, '', path);

    _addRouteEntry();
  }

  void _pushHistory({final String? path}) {
    if (path != null) {
      _popAllModalPoppers();

      // TODO@Hawmex: Fix calling `history.pushState` after `history.back`
      Timer(const Duration(milliseconds: 16), () {
        html.window.history.pushState(null, '', path);

        _addRouteEntry();
      });
    } else {
      html.window.history.pushState(null, '', null);
    }
  }

  void _pop() => html.window.history.back();

  void _replaceRoute(final String path) => _replaceHistory(path);

  void _pushRoute(final String path) => _pushHistory(path: path);

  void _pushModal({required final void Function() onPop}) =>
      _addModalPopper(onPop);

  void _historyBackHandler() {
    if (_modalPoppers.isNotEmpty) {
      _popModalPoppers();
    } else {
      _popRouteEntries();
    }
  }

  @override
  void initialize() {
    super.initialize();

    Navigator._state = this;

    _replaceHistory(html.window.location.pathname!);

    _historyBackSubscription = html.window.on['__navand-navigator-back__']
        .listen((final event) => _historyBackHandler());
  }

  @override
  void dispose() {
    _historyBackSubscription.cancel();

    Navigator._state = null;

    super.dispose();
  }

  Widget _build(final BuildContext context) {
    final url = Uri.parse(html.window.location.href);
    final segments = url.path.split('/');
    final params = <String, String>{};

    for (final route in widget.routes) {
      final result = _getMatchingRoute(
        route: route,
        segments: [...segments]..removeAt(0),
        params: params,
      );

      if (result != null) {
        final state = RouteState(
          path: url.path,
          params: params,
          queryParams: url.queryParameters,
        );

        if (result.redirector != null) {
          final redirectResult = result.redirector!(context, state);

          if (redirectResult != null) {
            _replaceRoute(redirectResult);

            return const Container([]);
          }
        }

        return result.builder!(context, state);
      }
    }

    throw StateError('No matching route was found.');
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      [for (final routeEntry in _routeEntries) routeEntry.wrappedWidget],
      style: const Style({'position': 'relative'}),
    );
  }
}
