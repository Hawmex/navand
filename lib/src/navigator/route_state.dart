import 'route.dart';

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
