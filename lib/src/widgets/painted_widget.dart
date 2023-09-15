import 'dart:async';
import 'dart:html' as html;

import '../animation/animation.dart';
import '../core/events.dart';
import '../core/style.dart';
import 'widget.dart';

/// The base class for widgets that paint an [html.Element].
abstract base class PaintedWidget extends Widget {
  final Style? style;
  final Animation? animation;

  final EventCallback? onTap;

  final PointerEventCallback? onPointerDown;
  final PointerEventCallback? onPointerUp;
  final PointerEventCallback? onPointerEnter;
  final PointerEventCallback? onPointerLeave;
  final PointerEventCallback? onPointerMove;
  final PointerEventCallback? onPointerCancel;
  final PointerEventCallback? onPointerOver;
  final PointerEventCallback? onPointerOut;

  const PaintedWidget({
    this.style,
    this.animation,
    this.onTap,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerEnter,
    this.onPointerLeave,
    this.onPointerMove,
    this.onPointerCancel,
    this.onPointerOver,
    this.onPointerOut,
    super.key,
    super.ref,
  });

  @override
  PaintedNode createNode();
}

/// A [Node] corresponding to [PaintedWidget].
base mixin PaintedNode<T extends PaintedWidget, U extends html.Element>
    on Node<T> {
  static PaintedNode? _getLastPaintedChild(final Node? node) {
    if (node is PaintedNode) return node;

    if (node is SingleChildNode) {
      return _getLastPaintedChild(node.child);
    }

    if (node is MultiChildNode) {
      if (node.children.isEmpty) {
        return _getLastPaintedChild(node.previous);
      }

      return _getLastPaintedChild(node.children.last);
    }

    return null;
  }

  /// The corresponding [html.Element] to this [PaintedNode].
  U get element;

  final _eventSubscriptions = <StreamSubscription<html.Event>>{};

  late final _parentPaintedNode = Node.getAncestorWhere(
    this,
    (final ancestor) => ancestor is PaintedNode,
  ) as PaintedNode?;

  late final html.Animation? _animation;

  PaintedNode? get _previousPaintedNode {
    Node? currentNode = this;

    while (currentNode != null) {
      if (currentNode != this && currentNode == _parentPaintedNode) break;

      final result = _getLastPaintedChild(currentNode.previous);

      if (result != null) return result;

      currentNode =
          currentNode.parent != _parentPaintedNode ? currentNode.parent : null;
    }

    return null;
  }

  /// Adds an event subscription to [type] with [callback].
  void addEventSubscription<V extends html.Event, W extends EventDetails<V>>({
    required final String type,
    required final EventCallback<W>? callback,
    required final W Function(V event) eventTransformer,
  }) {
    if (callback != null) {
      _eventSubscriptions.add(
        element.on[type].listen((final event) {
          callback(eventTransformer(event as V));
        }),
      );
    }
  }

  /// Called when this [Node] is added to the tree or after the [widget] is
  /// updated.
  void assembleElement() {
    addEventSubscription(
      type: 'click',
      callback: widget.onTap,
      eventTransformer: (final html.Event event) {
        return EventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointerdown',
      callback: widget.onPointerDown,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointerup',
      callback: widget.onPointerUp,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointerenter',
      callback: widget.onPointerEnter,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointerleave',
      callback: widget.onPointerLeave,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointermove',
      callback: widget.onPointerMove,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointercancel',
      callback: widget.onPointerCancel,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointerover',
      callback: widget.onPointerOver,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    addEventSubscription(
      type: 'pointerout',
      callback: widget.onPointerOut,
      eventTransformer: (final html.PointerEvent event) {
        return PointerEventDetails(event, targetNode: this);
      },
    );

    if (widget.style == null) {
      element.removeAttribute('style');
    } else {
      element.setAttribute('style', widget.style!.toString());
    }
  }

  /// Called before the [widget] is updated or when this [Node] is removed from
  /// the tree.
  void disassembleElement() {
    for (final eventSubscription in _eventSubscriptions) {
      eventSubscription.cancel();
    }

    _eventSubscriptions.clear();
  }

  @override
  void initialize() {
    super.initialize();

    final parentElement = _parentPaintedNode?.element ?? html.document.body!;

    if (_previousPaintedNode == null) {
      parentElement.insertBefore(element, parentElement.firstChild);
    } else {
      _previousPaintedNode!.element.after(element);
    }

    assembleElement();

    _animation = widget.animation?.runOnElement(element);
  }

  @override
  void widgetWillUpdate(final T newWidget) {
    disassembleElement();
    super.widgetWillUpdate(newWidget);
  }

  @override
  void widgetDidUpdate(final T oldWidget) {
    super.widgetDidUpdate(oldWidget);
    assembleElement();
  }

  @override
  void dispose() {
    _animation?.cancel();
    disassembleElement();
    element.remove();
    super.dispose();
  }
}

/// A [PaintedNode] with no children.
abstract base class ChildlessPaintedNode<T extends PaintedWidget,
    U extends html.Element> extends Node<T> with PaintedNode<T, U> {
  @override
  final U element;

  ChildlessPaintedNode(super.widget, {required this.element});
}

/// A [PaintedNode] with a child.
abstract base class SingleChildPaintedNode<T extends PaintedWidget,
    U extends html.Element> extends SingleChildNode<T> with PaintedNode<T, U> {
  @override
  final U element;

  SingleChildPaintedNode(super.widget, {required this.element});
}

/// A [PaintedNode] with children.
abstract base class MultiChildPaintedNode<T extends PaintedWidget,
    U extends html.Element> extends MultiChildNode<T> with PaintedNode<T, U> {
  @override
  final U element;

  MultiChildPaintedNode(super.widget, {required this.element});
}
