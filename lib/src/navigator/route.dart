import 'route_redirector.dart';
import 'route_widget_builder.dart';

/// The variant of a [Route].
///
/// - If [Route.path] is `*`, route variant is equivalent to [wildcard].
/// - If [Route.path] starts with `:`, route variant is equivalent to [dynamic].
/// - Else, route variant is equivalent to [static].
enum RouteVariant { static, dynamic, wildcard }

/// A class to declare routes using [path], [builder], and [routes].
final class Route {
  final String path;
  final List<Route> routes;
  final RouteWidgetBuilder? builder;
  final RouteRedirector? redirector;

  /// Creates a new [Route].
  const Route({
    required this.path,
    this.builder,
    this.redirector,
    this.routes = const [],
  });

  /// The [RouteVariant] of this [Route].
  RouteVariant get variant {
    if (path == '*') return RouteVariant.wildcard;
    if (path.startsWith(':')) return RouteVariant.dynamic;

    return RouteVariant.static;
  }
}
