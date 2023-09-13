import 'dart:html' as html;

import '../core/events.dart';
import 'painted_widget.dart';
import 'widget.dart';

/// A [Widget] that paints an [html.DivElement].
final class Container extends PaintedWidget {
  final List<Widget> children;

  final EventCallback? onScroll;

  /// Creates a new [Container].
  const Container(
    this.children, {
    super.style,
    super.animation,
    super.onTap,
    super.onPointerDown,
    super.onPointerUp,
    super.onPointerEnter,
    super.onPointerLeave,
    super.onPointerMove,
    super.onPointerCancel,
    super.onPointerOver,
    super.onPointerOut,
    this.onScroll,
    super.key,
    super.ref,
  });

  @override
  ContainerNode createNode() => ContainerNode(this);
}

/// A [Node] corresponding to [Container].
final class ContainerNode
    extends MultiChildPaintedNode<Container, html.DivElement> {
  /// Creates a new [ContainerNode].
  ContainerNode(super.widget) : super(element: html.DivElement());

  @override
  List<Widget> get childWidgets => widget.children;

  @override
  void assembleElement() {
    super.assembleElement();

    addEventSubscription(
      type: 'scroll',
      callback: widget.onScroll,
      eventTransformer: (final html.Event event) {
        return EventDetails(event, targetNode: this);
      },
    );
  }
}
