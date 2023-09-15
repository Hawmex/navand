import 'dart:async';
import 'dart:collection';
import 'dart:html' as html;

import '../core/build_context.dart';
import '../core/debouncer.dart';
import 'inherited_widget.dart';
import 'painted_widget.dart';
import 'stateful_widget.dart';

/// The base class for Navand widgets.
abstract base class Widget {
  final String? key;
  final Ref? ref;

  const Widget({this.key, this.ref});

  /// Returns the [Node] corresponding to this [Widget], at a particular
  /// location in the [Node] tree.
  Node createNode();

  /// Checks if two widgets match during a [ReassemblableNode] reassembly.
  ///
  /// - If the return value is `true`, the child [Node] is updated.
  /// - If the return value is `false`, the child [Node] is replaced by a new
  ///   one.
  bool matches(final Widget otherWidget) {
    return runtimeType == otherWidget.runtimeType && key == otherWidget.key;
  }
}

/// Similar to `ref` in React and `GlobalKey` in Flutter.
final class Ref {
  Node? _currentNode;

  /// Creates a new [Ref].
  Ref();

  /// The [Widget] in the tree that points to this [Ref].
  Widget? get currentWidget => _currentNode?.widget;

  /// The [State] of the [Widget] in the tree that points to this [Ref].
  State? get currentState {
    if (_currentNode is StatefulNode) {
      return (_currentNode as StatefulNode).state;
    }

    return null;
  }

  /// The [html.Element] of the [Widget] in the tree that points to this [Ref].
  html.Element? get currentElement {
    if (_currentNode is PaintedNode) {
      return (_currentNode as PaintedNode).element;
    }

    return null;
  }

  /// The [BuildContext] of the [Widget] in the tree that points to this [Ref].
  BuildContext? get currentContext => _currentNode?.context;
}

/// An instantiation of a [Widget] at a particular location in the [Node] tree.
abstract base class Node<T extends Widget> extends LinkedListEntry<Node> {
  static Node? getAncestorWhere(
    final Node node,
    final bool Function(Node ancestor) test,
  ) {
    if (node.parent == null) return null;
    if (test(node.parent!)) return node.parent;

    return getAncestorWhere(node.parent!, test);
  }

  bool _isActive = false;
  T _widget;

  final _dependencySubscriptions = HashSet<StreamSubscription<void>>();

  late final context = BuildContext(this);
  late final Node? parent;

  Node(this._widget);

  T get widget => _widget;

  /// If [widget] is updated while this [Node] is present in the [Node] tree,
  /// [widgetWillUpdate] and [widgetDidUpdate] are called.
  set widget(final T newWidget) {
    final oldWidget = widget;

    if (newWidget != oldWidget) {
      widgetWillUpdate(newWidget);

      _widget = newWidget;

      widgetDidUpdate(oldWidget);
    }
  }

  /// Returns the nearest parent [InheritedWidget] with the exact type [U].
  ///
  /// Also, if the parent [InheritedWidget] is updated, [dependenciesDidUpdate]
  /// is called.
  U dependOnInheritedWidgetOfExactType<U extends InheritedWidget>() {
    final inheritedNode = getAncestorWhere(
      this,
      (final ancestor) => ancestor.widget.runtimeType == U,
    ) as InheritedNode;

    late final StreamSubscription<void> subscription;

    subscription = inheritedNode.listen(() {
      subscription.cancel();
      dependenciesDidUpdate();
    });

    _dependencySubscriptions.add(subscription);

    return inheritedNode.widget as U;
  }

  /// Called right after this [Node] is added to the [Node] tree.
  ///
  /// *Flowing downwards*
  void initialize() {
    if (_isActive) throw StateError('Cannot initialize an active node');

    _isActive = true;
    widget.ref?._currentNode = this;
  }

  /// Called right before the [widget] is updated. Use this to remove references
  /// to the current widget that is being disposed.
  void widgetWillUpdate(final T newWidget) {
    widget.ref?._currentNode = null;
  }

  /// Called right after the [widget] is updated. Use this to initialize the new
  /// [widget].
  void widgetDidUpdate(final T oldWidget) {
    widget.ref?._currentNode = this;
  }

  /// Called after the dependencies are updated.
  void dependenciesDidUpdate() {}

  /// Called right after this [Node] and its children are completely removed
  /// from the [Node] tree.
  ///
  /// *Flowing upwards*
  void dispose() {
    if (!_isActive) throw StateError('Cannot dispose an inactive node.');

    for (final dependencySubscription in _dependencySubscriptions) {
      dependencySubscription.cancel();
    }

    _dependencySubscriptions.clear();

    widget.ref?._currentNode = null;
    _isActive = false;
  }
}

/// A [Node] with a child or children in the [Node] tree.
base mixin ReassemblableNode<T extends Widget> on Node<T> {
  final _reassemblyDebouncer = Debouncer();

  /// Updates or replaces this [ReassemblableNode]'s child or children.
  void reassemble();

  /// Debounces multiple calls to [reassemble].
  void enqueueReassembly() {
    _reassemblyDebouncer.scheduleTask(() {
      if (_isActive) reassemble();
    });
  }

  @override
  void widgetDidUpdate(final T oldWidget) {
    super.widgetDidUpdate(oldWidget);
    enqueueReassembly();
  }

  @override
  void dependenciesDidUpdate() {
    super.dependenciesDidUpdate();
    enqueueReassembly();
  }
}

/// A [ReassemblableNode] with a child in the [Node] tree.
abstract base class SingleChildNode<T extends Widget> extends Node<T>
    with ReassemblableNode<T> {
  late Node child;

  SingleChildNode(super.widget);

  Widget get childWidget;

  @override
  void initialize() {
    super.initialize();

    child = childWidget.createNode()
      ..parent = this
      ..initialize();
  }

  @override
  void reassemble() {
    if (childWidget.matches(child.widget)) {
      child.widget = childWidget;
    } else {
      child.dispose();

      child = childWidget.createNode()
        ..parent = this
        ..initialize();
    }
  }

  @override
  void dispose() {
    child.dispose();
    super.dispose();
  }
}

abstract base class MultiChildNode<T extends Widget> extends Node<T>
    with ReassemblableNode<T> {
  late LinkedList<Node> children;

  MultiChildNode(super.widget);

  List<Widget> get childWidgets;

  List<Widget> get _sanitizedChildWidgets {
    final explicitKeys = childWidgets
        .map((final childWidget) => childWidget.key)
        .toList()
      ..removeWhere((final key) => key == null);

    final uniqueExplicitKeys = explicitKeys.toSet();

    if (explicitKeys.length != uniqueExplicitKeys.length) {
      throw StateError(
        "Unique explicit keys must be provided in each MultiChildNode",
      );
    }

    return childWidgets;
  }

  @override
  void initialize() {
    super.initialize();

    children = LinkedList<Node>();

    for (final childWidget in _sanitizedChildWidgets) {
      final child = childWidget.createNode();

      children.add(child);

      child
        ..parent = this
        ..initialize();
    }
  }

  @override
  void reassemble() {
    final oldChildren = children;
    final newChildren = LinkedList<Node>();
    final newChildWidgets = _sanitizedChildWidgets;

    for (final newChildWidget in newChildWidgets) {
      Node? oldChild = oldChildren.firstOrNull;
      bool didReuse = false;

      while (oldChild != null) {
        if (oldChild.widget == newChildWidget ||
            oldChild.widget.matches(newChildWidget)) {
          newChildren.add(oldChild..unlink());

          oldChild.widget = newChildWidget;
          didReuse = true;

          break;
        }

        oldChild = oldChild.next;
      }

      if (!didReuse) {
        final newChild = newChildWidget.createNode();

        newChildren.add(newChild);

        newChild
          ..parent = this
          ..initialize();
      }
    }

    children = newChildren;

    while (oldChildren.lastOrNull != null) {
      oldChildren.last
        ..unlink()
        ..dispose();
    }
  }

  @override
  void dispose() {
    while (children.lastOrNull != null) {
      children.last
        ..unlink()
        ..dispose();
    }

    super.dispose();
  }
}
