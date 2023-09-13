import 'dart:async';

import 'widget.dart';

/// The base class for widgets that efficiently propagate information down the
/// tree.
abstract base class InheritedWidget extends Widget {
  final Widget child;

  const InheritedWidget({required this.child, super.key, super.ref});

  @override
  InheritedNode createNode() => InheritedNode(this);

  /// Whether [ReassemblableNode.reassemble] should be called on dependent nodes
  /// after this widget is updated.
  bool updateShouldNotify(covariant final InheritedWidget oldWidget);
}

/// A [Node] corresponding to [InheritedWidget].
final class InheritedNode<T extends InheritedWidget>
    extends SingleChildNode<T> {
  late final StreamController<void> _updateStreamController;

  /// Creates a new [InheritedNode].
  InheritedNode(super.widget);

  @override
  Widget get childWidget => widget.child;

  /// Listens to this [InheritedWidget] to get notified when it's updated.
  StreamSubscription<void> listen(final void Function() onUpdate) {
    return _updateStreamController.stream.listen((final event) {
      onUpdate();
    });
  }

  @override
  void initialize() {
    _updateStreamController = StreamController.broadcast();
    super.initialize();
  }

  @override
  void widgetDidUpdate(final T oldWidget) {
    super.widgetDidUpdate(oldWidget);

    if (widget.updateShouldNotify(oldWidget)) _updateStreamController.add(null);
  }

  @override
  void dispose() {
    super.dispose();
    _updateStreamController.close();
  }
}
