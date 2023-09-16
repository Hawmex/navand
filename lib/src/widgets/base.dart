part of widgets;

@JS('__navandAppNode__')
external _Node? _appNode;

/// Attaches the given [app] to the document's body by initializing it.
///
/// Note that supporting stateful hot-reload is considered necessary, but this
/// feature has been blocked by Dart's limitations. See
/// https://github.com/flutter/flutter/issues/53041
void runApp(final Widget app) {
  // ignore: avoid_print
  print(r'''
  _   _                            _ 
 | \ | |                          | |
 |  \| | __ ___   ____ _ _ __   __| |
 | . ` |/ _` \ \ / / _` | '_ \ / _` |
 | |\  | (_| |\ V / (_| | | | | (_| |
 |_| \_|\__,_| \_/ \__,_|_| |_|\__,_|
                                                       
''');

  _addBackEventScript();

  if (_appNode != null && app.matches(_appNode!._widget)) {
    _appNode!._widget = app;
  } else {
    _appNode?._dispose();

    _appNode = app._createNode()
      .._parent = null
      .._initialize();
  }
}

/// The location of a specific [Widget] in the tree.
final class BuildContext {
  late final _Node _node;

  /// Returns the nearest [InheritedWidget] with the exact type [T]. If the
  /// [InheritedWidget] is updated, the part of the tree with this context is
  /// rebuilt.
  ///
  /// Also, if the node owning this context is a stateful,
  /// [State.dependenciesDidUpdate] will be called.
  T dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return _node._dependOnInheritedWidgetOfExactType<T>();
  }
}

/// Similar to `ref` in React and `GlobalKey` in Flutter.
final class Ref {
  _Node? _node;

  /// Creates a new [Ref].
  Ref();

  /// The [Widget] in the tree that points to this [Ref].
  Widget? get currentWidget => _node?._widget;

  /// The [State] of the [Widget] in the tree that points to this [Ref].
  State? get currentState {
    return switch (_node) {
      final _StatefulNode node => node._state,
      _ => null,
    };
  }

  /// The [html.Element] of the [Widget] in the tree that points to this [Ref].
  html.Element? get currentElement {
    return switch (_node) {
      final _DomWidgetNode node => node._element,
      _ => null,
    };
  }

  /// The [BuildContext] of the [Widget] in the tree that points to this [Ref].
  BuildContext? get currentContext => _node?._context;
}

/// The base class for Navand widgets.
sealed class Widget {
  final String? key;
  final Ref? ref;

  const Widget({this.key, this.ref});

  _Node _createNode();

  /// Checks if two widgets match during a node reassembly.
  ///
  /// - If the return value is `true`, the child node is updated.
  /// - If the return value is `false`, the child node is replaced by a new one.
  bool matches(final Widget otherWidget) {
    return runtimeType == otherWidget.runtimeType && key == otherWidget.key;
  }
}

sealed class _Node<T extends Widget> extends LinkedListEntry<_Node> {
  static _Node? _getAncestorWhere(
    final _Node node,
    final bool Function(_Node ancestor) test,
  ) {
    if (node._parent == null) return null;
    if (test(node._parent!)) return node._parent;

    return _getAncestorWhere(node._parent!, test);
  }

  bool _isActive = false;
  T __widget;

  final _dependencySubscriptions = HashSet<StreamSubscription<void>>();

  late final _context = BuildContext().._node = this;
  late final _Node? _parent;

  _Node(this.__widget);

  T get _widget => __widget;

  set _widget(final T newWidget) {
    final oldWidget = _widget;

    if (newWidget != oldWidget) {
      _widgetWillUpdate(newWidget);

      __widget = newWidget;

      _widgetDidUpdate(oldWidget);
    }
  }

  U _dependOnInheritedWidgetOfExactType<U extends InheritedWidget>() {
    final inheritedNode = _getAncestorWhere(
      this,
      (final ancestor) => ancestor._widget.runtimeType == U,
    ) as _InheritedNode;

    late final StreamSubscription<void> subscription;

    subscription = inheritedNode._listen(() {
      subscription.cancel();
      _dependenciesDidUpdate();
    });

    _dependencySubscriptions.add(subscription);

    return inheritedNode._widget as U;
  }

  void _initialize() {
    _isActive = true;
    _widget.ref?._node = this;
  }

  void _widgetWillUpdate(final T newWidget) => _widget.ref?._node = null;
  void _widgetDidUpdate(final T oldWidget) => _widget.ref?._node = this;

  void _dependenciesDidUpdate() {}

  void _dispose() {
    for (final dependencySubscription in _dependencySubscriptions) {
      dependencySubscription.cancel();
    }

    _dependencySubscriptions.clear();

    _widget.ref?._node = null;
    _isActive = false;
  }
}

/// The base class for widgets that efficiently propagate information down the
/// tree.
abstract base class InheritedWidget extends Widget {
  final Widget child;

  const InheritedWidget({required this.child, super.key, super.ref});

  @override
  _InheritedNode _createNode() => _InheritedNode(this);

  /// Whether dependant nodes have to be updated after this widget was updated.
  bool updateShouldNotify(covariant final InheritedWidget oldWidget);
}

final class _InheritedNode extends _SingleChildNode<InheritedWidget> {
  late final StreamController<void> _updateStreamController;

  _InheritedNode(super.widget);

  @override
  Widget get _childWidget => _widget.child;

  StreamSubscription<void> _listen(final void Function() onUpdate) {
    return _updateStreamController.stream.listen((final event) {
      onUpdate();
    });
  }

  @override
  void _initialize() {
    _updateStreamController = StreamController.broadcast();
    super._initialize();
  }

  @override
  void _widgetDidUpdate(final InheritedWidget oldWidget) {
    super._widgetDidUpdate(oldWidget);

    if (_widget.updateShouldNotify(oldWidget)) {
      _updateStreamController.add(null);
    }
  }

  @override
  void _dispose() {
    super._dispose();
    _updateStreamController.close();
  }
}

base mixin _ReassemblableNode<T extends Widget> on _Node<T> {
  final _reassemblyDebouncer = Debouncer();

  void _reassemble();

  void _enqueueReassembly() {
    _reassemblyDebouncer.scheduleTask(() {
      if (_isActive) _reassemble();
    });
  }

  @override
  void _widgetDidUpdate(final T oldWidget) {
    super._widgetDidUpdate(oldWidget);
    _enqueueReassembly();
  }

  @override
  void _dependenciesDidUpdate() {
    super._dependenciesDidUpdate();
    _enqueueReassembly();
  }
}

sealed class _SingleChildNode<T extends Widget> extends _Node<T>
    with _ReassemblableNode<T> {
  late _Node _child;

  _SingleChildNode(super.widget);

  Widget get _childWidget;

  @override
  void _initialize() {
    super._initialize();

    _child = _childWidget._createNode()
      .._parent = this
      .._initialize();
  }

  @override
  void _reassemble() {
    if (_childWidget.matches(_child._widget)) {
      _child._widget = _childWidget;
    } else {
      _child._dispose();

      _child = _childWidget._createNode()
        .._parent = this
        .._initialize();
    }
  }

  @override
  void _dispose() {
    _child._dispose();
    super._dispose();
  }
}

sealed class _MultiChildNode<T extends Widget> extends _Node<T>
    with _ReassemblableNode<T> {
  late LinkedList<_Node> _children;

  _MultiChildNode(super.widget);

  List<Widget> get _childWidgets;

  List<Widget> get _sanitizedChildWidgets {
    final explicitKeys = _childWidgets
        .map((final childWidget) => childWidget.key)
        .toList()
      ..removeWhere((final key) => key == null);

    final uniqueExplicitKeys = explicitKeys.toSet();

    if (explicitKeys.length != uniqueExplicitKeys.length) {
      throw StateError(
        "Unique explicit keys must be provided in each MultiChildNode",
      );
    }

    return _childWidgets;
  }

  @override
  void _initialize() {
    super._initialize();

    _children = LinkedList<_Node>();

    for (final childWidget in _sanitizedChildWidgets) {
      final child = childWidget._createNode();

      _children.add(child);

      child
        .._parent = this
        .._initialize();
    }
  }

  @override
  void _reassemble() {
    final oldChildren = _children;
    final newChildren = LinkedList<_Node>();
    final newChildWidgets = _sanitizedChildWidgets;

    for (final newChildWidget in newChildWidgets) {
      _Node? oldChild = oldChildren.firstOrNull;
      bool didReuse = false;

      while (oldChild != null) {
        if (oldChild._widget == newChildWidget ||
            oldChild._widget.matches(newChildWidget)) {
          newChildren.add(oldChild..unlink());

          oldChild._widget = newChildWidget;
          didReuse = true;

          break;
        }

        oldChild = oldChild.next;
      }

      if (!didReuse) {
        final newChild = newChildWidget._createNode();

        newChildren.add(newChild);

        newChild
          .._parent = this
          .._initialize();
      }
    }

    _children = newChildren;

    while (oldChildren.lastOrNull != null) {
      oldChildren.last
        ..unlink()
        .._dispose();
    }
  }

  @override
  void _dispose() {
    while (_children.lastOrNull != null) {
      _children.last
        ..unlink()
        .._dispose();
    }

    super._dispose();
  }
}

/// A [Widget] that does not have a mutable state.
abstract base class StatelessWidget extends Widget {
  const StatelessWidget({super.key, super.ref});

  /// Returns a single widget with the given [context].
  Widget build(final BuildContext context);

  @override
  _StatelessNode _createNode() => _StatelessNode(this);
}

final class _StatelessNode<T extends StatelessWidget>
    extends _SingleChildNode<T> {
  _StatelessNode(super.widget);

  @override
  Widget get _childWidget => _widget.build(_context);
}

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

/// A widget that can render multiple children.
final class Fragment extends Widget {
  final List<Widget> children;

  const Fragment(this.children, {super.key, super.ref});

  @override
  _FragmentNode _createNode() => _FragmentNode(this);
}

final class _FragmentNode extends _MultiChildNode<Fragment> {
  _FragmentNode(super.widget);

  @override
  List<Widget> get _childWidgets => _widget.children;
}
