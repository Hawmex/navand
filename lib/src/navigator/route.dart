import 'route_redirector.dart';
import 'route_widget_builder.dart';

/// The variant of a [Route].
///
/// - If [Route.path] is `*`, route variant is equivalent to [wildcard].
/// - If [Route.path] starts with `:`, route variant is equivalent to [dynamic].
/// - Else, route variant is equivalent to [static].
enum RouteVariant {
  static,
  dynamic,
  wildcard,
}

/// A class to declare routes using [path], [builder], and [routes].
final class Route {
  static void validateRoutes(final List<Route> routes) {
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
    validateRoutes(routes);
  }

  /// The [RouteVariant] of this [Route].
  RouteVariant get variant {
    if (path == '*') return RouteVariant.wildcard;
    if (path.startsWith(':')) return RouteVariant.dynamic;

    return RouteVariant.static;
  }
}
