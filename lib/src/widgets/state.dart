part of widgets;

/// A [Widget] that has a mutable state.
abstract base class StatefulWidget extends Widget {
  const StatefulWidget({super.key, super.ref});

  /// Creates the mutable state for this widget.
  State createState();

  @override
  _StatefulNode _createNode() => _StatefulNode(this);
}

/// A store that can notify its listeners when [setState] is called.
abstract base class Store {
  bool _isActive = false;

  late final StreamController<void> _updateController;

  /// Notifies the listeners.
  void setState(final void Function() callback) {
    callback();

    if (_isActive) _updateController.add(null);
  }

  /// Listens to this [Store] for notifications.
  StreamSubscription<void> listen(final void Function() onUpdate) {
    return _updateController.stream.listen((final event) {
      onUpdate();
    });
  }

  /// Initializes this [Store].
  void initialize() {
    if (_isActive) throw StateError('Cannot initialize an active store.');

    _isActive = true;
    _updateController = StreamController.broadcast();
  }

  /// Disposes this [Store].
  void dispose() {
    if (!_isActive) throw StateError('Cannot dispose an inactive store.');

    _updateController.close();
    _isActive = false;
  }
}

/// The logic and internal state for a [StatefulWidget].
abstract base class State<T extends StatefulWidget> extends Store {
  bool _isMounted = false;
  late T _widget;
  late final BuildContext _context;

  /// Whether this [State] is currently in the tree.
  bool get isMounted => _isMounted;

  /// The current configuration of this [State].
  T get widget => _widget;

  /// The location of this [State] in the tree.
  BuildContext get context => _context;

  /// Returns a single widget with the given [context].
  Widget build(final BuildContext context);

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

final class _StatefulNode extends _SingleChildNode<StatefulWidget> {
  late final State _state;
  late final StreamSubscription<void> _updateStreamSubscription;

  _StatefulNode(super.widget);

  @override
  Widget get _childWidget => _state.build(_context);

  @override
  void _initialize() {
    _state = _widget.createState()
      .._widget = _widget
      .._context = _context
      ..initialize();

    super._initialize();

    _updateStreamSubscription = _state.listen(_enqueueReassembly);
    _state.didMount();
  }

  @override
  void _widgetDidUpdate(final StatefulWidget oldWidget) {
    _state._widget = _widget;
    super._widgetDidUpdate(oldWidget);
    _state.widgetDidUpdate(oldWidget);
  }

  @override
  void _dependenciesDidUpdate() {
    super._dependenciesDidUpdate();
    _state.dependenciesDidUpdate();
  }

  @override
  void _dispose() {
    _state.willUnmount();
    _updateStreamSubscription.cancel();
    super._dispose();
    _state.dispose();
  }
}

/// The type of the function that updates a [State].
typedef StateSetter = void Function(void Function() callback);

/// The type of the builder function used in a [StatefulBuilder].
typedef StatefulWidgetBuilder = Widget Function(
  BuildContext context,
  StateSetter setState,
);

/// A widget that has a [State] and calls a closure to obtain its child
/// widget.
final class StatefulBuilder extends StatefulWidget {
  final StatefulWidgetBuilder builder;

  /// Creates a new [StatefulBuilder].
  const StatefulBuilder(this.builder, {super.key, super.ref});

  @override
  State createState() => _StatefulBuilderState();
}

final class _StatefulBuilderState<T extends StatefulBuilder> extends State<T> {
  @override
  Widget build(final BuildContext context) => widget.builder(context, setState);
}

/// [Provider] utilities that are added to [BuildContext].
extension ProviderHelpers on BuildContext {
  /// Returns the first [Store] with the exact type [T] provided by the
  /// nearest parent [Provider].
  ///
  /// Also, if the [Provider] is updated, the widget owning this
  /// context is rebuilt.
  T dependOnProvidedStoreOfExactType<T extends Store>() {
    return Provider.of(this)
        .stores
        .firstWhere((final store) => store.runtimeType == T) as T;
  }
}

/// A widget that propagates multiple [Store] instances down the tree.
///
/// **Notice:** It's the developer's responsibility to handle the initialization
/// and disposal of stores by calling [Store.initialize] and [Store.dispose]
/// whenever needed.
final class Provider extends InheritedWidget {
  final List<Store> stores;

  /// Creates a new [Provider].
  const Provider({
    required this.stores,
    required super.child,
    super.key,
    super.ref,
  });

  factory Provider.of(final BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  @override
  updateShouldNotify(final Provider oldWidget) => stores != oldWidget.stores;
}

/// A base class for widgets that are rebuilt with the latest state of a [Store]
/// provided by a [Provider].
abstract base class ConsumerWidget<T extends Store> extends StatefulWidget {
  const ConsumerWidget({super.key, super.ref});

  /// Returns a single widget with the given [context] and [store].
  Widget build(final BuildContext context, final T store);

  @override
  State createState() => _ConsumerWidgetState<T, ConsumerWidget<T>>();
}

final class _ConsumerWidgetState<T extends Store, U extends ConsumerWidget<T>>
    extends State<U> {
  late T _store;
  late StreamSubscription<void> _subscription;

  @override
  void initialize() {
    super.initialize();
    _store = context.dependOnProvidedStoreOfExactType<T>();
    _subscription = _store.listen(() => setState(() {}));
  }

  @override
  void dependenciesDidUpdate() {
    super.dependenciesDidUpdate();
    _subscription.cancel();
    _store = context.dependOnProvidedStoreOfExactType<T>();
    _subscription = _store.listen(() => setState(() {}));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => widget.build(context, _store);
}

/// The type of the builder function used in a [ConsumerBuilder].
typedef ConsumerWidgetBuilder<T extends Store> = Widget Function(
  BuildContext context,
  T store,
);

/// A widget that is rebuilt with the latest state of a [Store] provided by a
/// [Provider].
final class ConsumerBuilder<T extends Store> extends ConsumerWidget<T> {
  final ConsumerWidgetBuilder<T> builder;

  /// Creates a new [ConsumerBuilder].
  const ConsumerBuilder(this.builder, {super.key, super.ref});

  @override
  Widget build(final BuildContext context, final T store) {
    return builder(context, store);
  }
}
