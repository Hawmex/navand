import 'dart:async';

import '../core/build_context.dart';
import '../core/buildable.dart';
import '../core/store.dart';
import 'widget.dart';

/// A [Widget] that has a mutable state.
abstract base class StatefulWidget extends Widget {
  const StatefulWidget({super.key, super.ref});

  /// Creates the mutable state for this widget.
  State createState();

  @override
  StatefulNode createNode() => StatefulNode(this);
}

/// The logic and internal state for a [StatefulWidget].
abstract base class State<T extends StatefulWidget> extends Store
    with Buildable {
  bool _isMounted = false;
  late T _widget;
  late final BuildContext _context;

  /// Whether this [State] is currently in the [Node] tree.
  bool get isMounted => _isMounted;

  /// The current configuration of this [State].
  T get widget => _widget;

  /// The location of this [State] in the [Node] tree.
  BuildContext get context => _context;

  /// Called right after all child nodes are initialized.
  ///
  /// *Flowing upwards*
  void didMount() => _isMounted = true;

  /// Called right after the configuration is updated.
  void widgetDidUpdate(final T oldWidget) {}

  /// Called right after the dependencies are updated.
  void dependenciesDidUpdate() {}

  /// Called right before the removal of this [State] from the tree.
  ///
  /// *Flowing downwards*
  void willUnmount() => _isMounted = false;
}

/// A [Node] corresponding to [StatefulWidget].
final class StatefulNode<T extends StatefulWidget> extends SingleChildNode<T> {
  late final State<T> state;
  late final StreamSubscription<void> _updateStreamSubscription;

  /// Creates a new [StatefulNode].
  StatefulNode(super.widget);

  @override
  Widget get childWidget => state.build(context);

  @override
  void initialize() {
    state = widget.createState() as State<T>
      .._widget = widget
      .._context = context
      ..initialize();

    super.initialize();

    _updateStreamSubscription = state.listen(enqueueReassembly);
    state.didMount();
  }

  @override
  void widgetDidUpdate(final T oldWidget) {
    state._widget = widget;
    super.widgetDidUpdate(oldWidget);
    state.widgetDidUpdate(oldWidget);
  }

  @override
  void dependenciesDidUpdate() {
    super.dependenciesDidUpdate();
    state.dependenciesDidUpdate();
  }

  @override
  void dispose() {
    state.willUnmount();
    _updateStreamSubscription.cancel();
    super.dispose();
    state.dispose();
  }
}
