part of widgets;

const _script = r'''
let currentIndex = history.state?.index ?? 0;
let preventingForward = false;

if (!history.state || !("index" in history.state)) {
  history.replaceState(
    { index: currentIndex, state: history.state },
    document.title
  );
}

const getState = Object.getOwnPropertyDescriptor(
  History.prototype,
  "state"
).get;

const { pushState, replaceState } = history;

const onPopstate = () => {
  const state = getState.call(history);

  if (!state) {
    replaceState.call(history, { index: currentIndex + 1 }, document.title);
  }

  const index = state ? state.index : currentIndex + 1;

  if (index > currentIndex) {
    preventingForward = true;

    history.back();
  } else if (preventingForward) {
    preventingForward = false;
  } else {
    window.dispatchEvent(new Event("__navand-navigator-back__"));
  }

  currentIndex = index;
};

const modifyStateFunction = (func, n) => {
  return (state, ...args) => {
    func.call(history, { index: currentIndex + n, state }, ...args);

    currentIndex += n;
  };
};

const modifyStateGetter = (object) => {
  const { get } = Object.getOwnPropertyDescriptor(object.prototype, "state");

  Object.defineProperty(object.prototype, "state", {
    configurable: true,
    enumerable: true,
    set: undefined,
    get() {
      return get.call(this).state;
    },
  });
};

modifyStateGetter(History);
modifyStateGetter(PopStateEvent);

history.pushState = modifyStateFunction(pushState, 1);
history.replaceState = modifyStateFunction(replaceState, 0);

window.addEventListener("popstate", onPopstate);
''';

void _addBackEventScript() => js.context.callMethod('eval', [_script]);

/// The navigation state of the current [Route].
final class RouteState {
  final String path;
  final Map<String, String> params;
  final Map<String, String> queryParams;

  /// Creates a new [RouteState].
  const RouteState({
    required this.path,
    required this.params,
    required this.queryParams,
  });
}

/// The type of the builder function used in a [Route].
typedef RouteWidgetBuilder = Widget Function(
  BuildContext context,
  RouteState state,
);

/// The type of the redirector function used in a [Route].
typedef RouteRedirector = String? Function(
  BuildContext context,
  RouteState state,
);

/// The variant of a [Route].
///
/// - If [Route.path] is `*`, route variant is equivalent to [wildcard].
/// - If [Route.path] starts with `:`, route variant is equivalent to [dynamic].
/// - Else, route variant is equivalent to [static].
enum _RouteVariant {
  static,
  dynamic,
  wildcard,
}

/// A class to declare routes using [path], [builder], and [routes].
final class Route {
  static void _validateRoutes(final List<Route> routes) {
    final uniquePaths = routes.map((final route) => route.path).toSet();

    if (uniquePaths.length != routes.length) {
      throw StateError('Avoid using duplicate paths when declaring routes.');
    }
  }

  final String path;
  final List<Route> routes;
  final RouteWidgetBuilder? builder;
  final RouteRedirector? redirector;

  /// Creates a new [Route].
  Route({
    required this.path,
    this.builder,
    this.redirector,
    this.routes = const [],
  }) {
    _validateRoutes(routes);
  }

  _RouteVariant get _variant {
    if (path == '*') return _RouteVariant.wildcard;
    if (path.startsWith(':')) return _RouteVariant.dynamic;

    return _RouteVariant.static;
  }
}

/// The navigation outlet of a Navand app.
///
/// **Notice:** Only a single instance of [Navigator] should be present in an
/// app.
final class Navigator extends StatefulWidget {
  static _NavigatorState? _state;

  /// Pops all modals and replaces the current route.
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
  /// pushed.
  final Animation? pushAnimation;

  /// The animation that should be applied to the latest route after it's been
  /// popped.
  final Animation? popAnimation;

  /// Creates a new [Navigator].
  Navigator({
    required this.routes,
    this.pushAnimation,
    this.popAnimation,
    super.key,
    super.ref,
  }) {
    Route._validateRoutes(routes);
  }

  @override
  State createState() => _NavigatorState();
}

final class _RouteEntry {
  final _ref = Ref();

  late final Widget _wrappedWidget = DomWidget(
    'div',
    children: [
      _widget,
    ],
    ref: _ref,
    style: Style({
      'position': 'absolute',
      'left': '0px',
      'top': '0px',
      'width': '100%',
      'height': '100%',
      if (!_visible) 'visibility': 'hidden',
    }),
  );

  final Widget _widget;
  final bool _visible;

  _RouteEntry(this._widget, {final bool visible = true}) : _visible = visible;
}

final class _NavigatorState extends State<Navigator> {
  static Route? _getMatchingRoute({
    required final Route route,
    required final List<String> segments,
    required final Map<String, String> params,
  }) {
    if (route._variant == _RouteVariant.wildcard) return route;

    if (route._variant == _RouteVariant.dynamic && segments.isNotEmpty) {
      params[route.path.substring(1)] = segments.first;
    }

    if (route._variant == _RouteVariant.static &&
        route.path != segments.first) {
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

  html.Animation? _currentAnimation;

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
    await _currentAnimation?.finished;

    if (_routeEntries.length == 1) {
      final routeEntry = _RouteEntry(_build(context));

      _routeEntries.insert(0, routeEntry);

      setState(() {});

      await _animationFrame;
    }

    final lastRouteElement = _routeEntries.removeLast()._ref.currentElement!;

    _routeEntries.last._ref.currentElement!.style.visibility = 'visible';
    _currentAnimation = widget.popAnimation?.runOnElement(lastRouteElement);

    await _currentAnimation!.finished;

    setState(() {});
  }

  Future<void> _addRouteEntry() async {
    await _currentAnimation?.finished;

    final lastRouteElement = _routeEntries.last._ref.currentElement;
    final newRouteEntry = _RouteEntry(_build(context), visible: false);

    _routeEntries.add(newRouteEntry);

    setState(() {});

    await _animationFrame;

    final newRouteElement = newRouteEntry._ref.currentElement!
      ..style.visibility = 'visible';

    _currentAnimation = widget.pushAnimation?.runOnElement(newRouteElement);

    await _currentAnimation!.finished;

    lastRouteElement?.style.visibility = 'hidden';
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
  void initialize() async {
    super.initialize();

    await _replaceRouteEntry();

    Navigator._state = this;

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

            return const Fragment([]);
          }
        }

        return result.builder!(context, state);
      }
    }

    throw StateError('No matching route was found.');
  }

  @override
  Widget build(final BuildContext context) {
    return DomWidget(
      'div',
      children: [
        for (final routeEntry in _routeEntries) routeEntry._wrappedWidget,
      ],
      style: const Style({'position': 'relative'}),
    );
  }
}
