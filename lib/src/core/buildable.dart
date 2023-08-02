import '../widgets/stateful_widget.dart';
import '../widgets/stateless_widget.dart';
import '../widgets/widget.dart';
import 'build_context.dart';

/// Adds the [build] function to classes such as [StatelessWidget] and [State].
base mixin Buildable {
  /// Returns a single widget with the given [context].
  Widget build(final BuildContext context);
}
