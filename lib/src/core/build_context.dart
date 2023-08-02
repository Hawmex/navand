import '../widgets/inherited_widget.dart';
import '../widgets/stateful_widget.dart';
import '../widgets/widget.dart';

/// The location of a specific [Widget] in the [Node] tree.
final class BuildContext {
  final Node _node;

  const BuildContext(this._node);

  /// Returns the nearest [InheritedWidget] with the exact type [T]. If the
  /// [InheritedWidget] is updated, the part of the [Node] tree with this
  /// context is rebuilt.
  ///
  /// Also, if the [Node] owning this context is a [StatefulNode],
  /// [State.dependenciesDidUpdate] will be called.
  T dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() =>
      _node.dependOnInheritedWidgetOfExactType<T>();
}
