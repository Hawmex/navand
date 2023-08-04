import '../core/build_context.dart';
import 'route.dart';
import 'route_state.dart';

/// The type of the redirector function used in a [Route].
typedef RouteRedirector = String? Function(
  BuildContext context,
  RouteState state,
);
