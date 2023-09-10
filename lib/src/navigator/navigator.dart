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

/// The navigation outlet of a Navand app.
///
/// **Notice:** Only a single instance of [Navigator] should be present in an
/// app.
final class Navigator extends StatefulWidget {
  static _NavigatorState? _state;

  /// Replaces the current route.
  static Future<void> replaceRoute(final String path) async {
    await _state!._replaceRoute(path);
  }

  /// Pops all modals and pushes a new route.
  static Future<void> pushRoute(final String path) async {
    await _state!._pushRoute(path);
  }

  /// Pushes a new modal.
  static Future<void> pushModal({required final void Function() onPop}) async {
    await _state!._pushModal(onPop: onPop);
  }

  /// Pops the latest modal. If no modal is open, the current route is popped.
  static Future<void> pop() async {
    await _state!._pop();
  }

  final List<Route> routes;

  /// The animation that should be applied to the latest route after it's been
  /// replaced or pushed.
  final Animation? pushAnimation;

  /// The animation that should be applied to the latest route after it's been
  /// popped.
  final Animation? popAnimation;

  /// Creates a new [Navigator].
  const Navigator({
    required this.routes,
    this.pushAnimation,
    this.popAnimation,
    super.key,
    super.ref,
  });

  @override
  State createState() => _NavigatorState();
}

final class _RouteEntry {
  final _ref = Ref();

  late final Widget _wrappedWidget = Container(
    [widget],
    ref: _ref,
    style: Style({
      'position': 'absolute',
      'left': '0px',
      'top': '0px',
      'width': '100%',
      'height': '100%',
      if (!visible) 'visibility': 'hidden',
    }),
  );

  final Widget widget;
  final bool visible;

  _RouteEntry(this.widget, {this.visible = true});
}

final class _NavigatorState extends State<Navigator> {
  static Route? _getMatchingRoute({
    required final Route route,
    required final List<String> segments,
    required final Map<String, String> params,
  }) {
    if (route.variant == RouteVariant.wildcard) return route;

    if (route.variant == RouteVariant.dynamic && segments.isNotEmpty) {
      params[route.path.substring(1)] = segments.first;
    }

    if (route.variant == RouteVariant.static &&
        route.path != (segments.firstOrNull ?? '')) {
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

  bool _waitForPop = false;

  late final StreamController<void> _popWaiter;
  late final StreamSubscription<html.Event> _historyBackSubscription;

  Future<void> get _animationFrame async {
    final controller = StreamController<void>.broadcast();

    Timer(const Duration(milliseconds: 16), () {
      controller.add(null);
    });

    await controller.stream.first;
  }

  Future<void> _popAllModalPoppers() async {
    final n = _modalPoppers.length;

    for (int i = 0; i < n; i++) {
      await _pop();
    }
  }

  void _popModalPoppers() {
    _modalPoppers.removeLast()();
  }

  Future<void> _addModalPopper(final void Function() popper) async {
    await _pushHistory();

    _modalPoppers.add(popper);
  }

  Future<void> _popRouteEntries() async {
    final lastRouteElement = _routeEntries.removeLast()._ref.currentElement!;

    await widget.popAnimation?.runOnElement(lastRouteElement).finished;

    setState(() {});
  }

  Future<void> _addRouteEntry() async {
    final routeEntry = _RouteEntry(_build(context), visible: false);

    _routeEntries.add(routeEntry);

    setState(() {});

    await _animationFrame;

    final routeElement = routeEntry._ref.currentElement!
      ..style.visibility = 'visible';

    await widget.pushAnimation?.runOnElement(routeElement).finished;
  }

  Future<void> _replaceRouteEntry() async {
    if (_routeEntries.isNotEmpty) _routeEntries.removeLast();

    final routeEntry = _RouteEntry(_build(context));

    _routeEntries.add(routeEntry);

    setState(() {});
  }

  Future<void> _replaceHistory(final String path) async {
    await _popAllModalPoppers();

    html.window.history.replaceState(null, '', path);

    await _animationFrame;

    await _replaceRouteEntry();
  }

  Future<void> _pushHistory([final String? path]) async {
    if (path != null) {
      await _popAllModalPoppers();

      html.window.history.pushState(null, '', path);

      await _animationFrame;

      await _addRouteEntry();
    } else {
      html.window.history.pushState(null, '', null);

      await _animationFrame;
    }
  }

  Future<void> _pop() async {
    _waitForPop = true;

    html.window.history.back();

    final controller = StreamController<void>.broadcast();

    late final StreamSubscription<void> subscription;

    subscription = _popWaiter.stream.listen((final event) {
      controller.add(null);
      subscription.cancel();
    });

    await controller.stream.first;
  }

  Future<void> _replaceRoute(final String path) async {
    await _replaceHistory(path);
  }

  Future<void> _pushRoute(final String path) async {
    await _pushHistory(path);
  }

  Future<void> _pushModal({required final void Function() onPop}) async {
    await _addModalPopper(onPop);
  }

  void _historyBackHandler() async {
    if (_modalPoppers.isNotEmpty) {
      _popModalPoppers();
    } else {
      await _popRouteEntries();
    }

    if (_waitForPop) {
      _waitForPop = false;

      _popWaiter.add(null);
    }
  }

  @override
  void initialize() {
    super.initialize();

    Navigator._state = this;

    _replaceHistory(html.window.location.href);

    _popWaiter = StreamController.broadcast();

    _historyBackSubscription = html.window.on['__navand-navigator-back__']
        .listen((final event) => _historyBackHandler());
  }

  @override
  void dispose() {
    _historyBackSubscription.cancel();
    _popWaiter.close();

    Navigator._state = null;

    super.dispose();
  }

  Widget _build(final BuildContext context) {
    final url = Uri.parse(html.window.location.href);
    final params = <String, String>{};

    for (final route in widget.routes) {
      final result = _getMatchingRoute(
        route: route,
        segments: [...url.pathSegments],
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
      [for (final routeEntry in _routeEntries) routeEntry._wrappedWidget],
      style: const Style({'position': 'relative'}),
    );
  }
}
