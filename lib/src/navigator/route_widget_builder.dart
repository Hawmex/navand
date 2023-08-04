import '../core/build_context.dart';
import '../widgets/widget.dart';
import 'route.dart';
import 'route_state.dart';

/// The type of the builder function used in a [Route].
typedef RouteWidgetBuilder = Widget Function(
  BuildContext context,
  RouteState state,
);
