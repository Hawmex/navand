part of widgets;

base mixin _DomNode<T extends Widget> on _Node<T> {
  late final _parentDomWidgetNode = _Node._getAncestorWhere(
    this,
    (final ancestor) => ancestor is _DomWidgetNode,
  ) as _DomWidgetNode?;

  html.Node get _htmlNode;

  _DomNode? _findDomNode(final _Node node, {final bool skip = false}) {
    if (skip) {
      if (node.previous != null) return _findDomNode(node.previous!);

      if (node._parent == null || node._parent == _parentDomWidgetNode) {
        return null;
      }

      return _findDomNode(node._parent!, skip: true);
    }

    if (node is _SingleChildNode) return _findDomNode(node._child);

    if (node is _FragmentNode) {
      if (node._children.isEmpty) return _findDomNode(node, skip: true);

      return _findDomNode(node._children.last);
    }

    return node as _DomNode;
  }

  _DomNode? get _previousDomNode => _findDomNode(this, skip: true);

  @override
  void _initialize() {
    super._initialize();

    final parentElement = _parentDomWidgetNode?._element ?? html.document.body!;

    if (_previousDomNode == null) {
      parentElement.insertBefore(_htmlNode, parentElement.firstChild);
    } else {
      (_previousDomNode!._htmlNode as dynamic).after(_htmlNode);
    }
  }

  @override
  void _dispose() {
    _htmlNode.remove();
    super._dispose();
  }
}

/// The callback function of events.
typedef EventCallback = void Function(EventDetails details);

/// The details of the fired event.
final class EventDetails {
  final html.Event current;
  late final _Node _node;

  /// Creates a new [EventDetails].
  EventDetails(this.current);

  /// The [Widget] in the tree that fired this event.
  Widget get targetWidget => _node._widget;

  /// The [State] of the [Widget] in the tree that fired this event.
  State? get targetState {
    return switch (_node) {
      final _StatefulNode node => node._state,
      _ => null,
    };
  }

  /// The [html.Element] of the [Widget] in the tree that fired this event.
  html.Element? get targetElement {
    return switch (_node) {
      final _DomWidgetNode node => node._element,
      _ => null,
    };
  }

  /// The [BuildContext] of the [Widget] in the tree that fired this event.
  BuildContext get targetContext => _node._context;
}

/// Describes how a [DomWidget] should look on the screens.
final class Style {
  final Map<String, String> _rules;

  /// Creates a new [Style].
  const Style(this._rules);

  /// Returns a map representation of this [Style] that can be used by
  /// JavaScript's animation API.
  Map<String, String> toKeyframeMap() {
    return _rules.map(
      (final key, final value) => MapEntry(
        key.fromKebabCaseToCamelCase(),
        value,
      ),
    );
  }

  /// Concatenates two styles.
  Style operator +(final Style? otherStyle) {
    return Style({
      ..._rules,
      if (otherStyle != null) ...otherStyle._rules,
    });
  }

  /// Concatenates two styles.
  Style addAll(final Style? otherStyle) => this + otherStyle;

  @override
  String toString() {
    if (_rules.isEmpty) return '';

    return _rules.entries
        .map((final ruleEntry) => '${ruleEntry.key}: ${ruleEntry.value}')
        .join('; ')
        .removeExtraWhitespace();
  }
}

final class DomWidget extends Widget {
  final String tag;
  final String? id;
  final List<Widget> children;
  final Set<String> classes;
  final Style? style;
  final Animation? animation;
  final Map<String, String> attributes;
  final Map<String, EventCallback> events;

  const DomWidget(
    this.tag, {
    this.id,
    this.children = const [],
    this.classes = const {},
    this.style,
    this.animation,
    this.attributes = const {},
    this.events = const {},
    super.key,
    super.ref,
  });

  @override
  _DomWidgetNode _createNode() => _DomWidgetNode(this);
}

final class _DomWidgetNode extends _MultiChildNode<DomWidget>
    with _DomNode<DomWidget> {
  final _eventSubscriptions = <StreamSubscription<html.Event>>{};

  late final html.Element _element = html.Element.tag(_widget.tag);
  late final html.Animation? _animation;

  _DomWidgetNode(super.widget);

  @override
  html.Node get _htmlNode => _element;

  @override
  List<Widget> get _childWidgets => _widget.children;

  void _assembleElement() {
    for (final entry in _widget.events.entries) {
      _eventSubscriptions.add(
        _element.on[entry.key].listen((final event) {
          entry.value(EventDetails(event).._node = this);
        }),
      );
    }

    for (final key in _element.attributes.keys) {
      if (!_widget.attributes.containsKey(key)) _element.removeAttribute(key);
    }

    for (final entry in _widget.attributes.entries) {
      _element.setAttribute(entry.key, entry.value);
    }

    if (_widget.style == null) {
      _element.removeAttribute('style');
    } else {
      _element.setAttribute('style', _widget.style!.toString());
    }

    for (final name in _element.classes.toSet()) {
      if (!_widget.classes.contains(name)) _element.classes.remove(name);
    }

    for (final name in _widget.classes) {
      _element.classes.add(name);
    }

    if (_widget.id == null) {
      _element.removeAttribute('id');
    } else {
      _element.setAttribute('id', _widget.id!);
    }
  }

  void _disassembleElement() {
    for (final eventSubscription in _eventSubscriptions) {
      eventSubscription.cancel();
    }

    _eventSubscriptions.clear();
  }

  @override
  void _initialize() {
    super._initialize();
    _assembleElement();
    _animation = _widget.animation?.runOnElement(_element);
  }

  @override
  void _widgetWillUpdate(final DomWidget newWidget) {
    _disassembleElement();
    super._widgetWillUpdate(newWidget);
  }

  @override
  void _widgetDidUpdate(final DomWidget oldWidget) {
    super._widgetDidUpdate(oldWidget);
    _assembleElement();
  }

  @override
  void _dispose() {
    _animation?.cancel();
    _disassembleElement();
    super._dispose();
  }
}

final class Text extends Widget {
  final String value;

  const Text(this.value, {super.key, super.ref});

  @override
  _TextNode _createNode() => _TextNode(this);
}

final class _TextNode extends _Node<Text> with _DomNode<Text> {
  late final __htmlNode = html.Text('');

  _TextNode(super.widget);

  @override
  html.Node get _htmlNode => __htmlNode;

  @override
  void _initialize() {
    super._initialize();
    __htmlNode.text = _widget.value;
  }

  @override
  void _widgetDidUpdate(final Text oldWidget) {
    super._widgetDidUpdate(oldWidget);
    __htmlNode.text = _widget.value;
  }
}
