import '../core/build_context.dart';
import 'stateless_widget.dart';
import 'widget.dart';

/// The type of the builder function used in a [StatelessBuilder].
typedef StatelessWidgetBuilder = Widget Function(BuildContext context);

/// A stateless utility [Widget] whose build method uses its builder callback to
/// create its child.
final class StatelessBuilder extends StatelessWidget {
  final StatelessWidgetBuilder builder;

  /// Creates a new [StatelessBuilder].
  const StatelessBuilder(this.builder, {super.key, super.ref});

  @override
  Widget build(final BuildContext context) => builder(context);
}
