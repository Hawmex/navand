import 'dart:html' as html;

import 'painted_widget.dart';
import 'widget.dart';

/// A [Widget] that paints an [html.SpanElement].
final class Text extends PaintedWidget {
  final String value;

  /// Creates a new [Text].
  const Text(
    this.value, {
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
    super.key,
    super.ref,
  });

  @override
  TextNode createNode() => TextNode(this);
}

/// A [Node] corresponding to [Text].
final class TextNode extends ChildlessPaintedNode<Text, html.SpanElement> {
  /// Creates a new [TextNode].
  TextNode(super.widget) : super(element: html.SpanElement());

  @override
  void assembleElement() {
    super.assembleElement();
    element.text = widget.value;
  }
}
