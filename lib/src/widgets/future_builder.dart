import '../core/async_snapshot.dart';
import '../core/async_widget_builder.dart';
import '../core/build_context.dart';
import 'stateful_widget.dart';
import 'widget.dart';

/// A [Widget] that is rebuilt with the latest snapshot of a [Future].
final class FutureBuilder<T> extends StatefulWidget {
  final AsyncWidgetBuilder<T> builder;
  final Future<T>? future;
  final T? initialData;

  /// Creates a new [FutureBuilder].
  const FutureBuilder(
    this.builder, {
    this.future,
    this.initialData,
    super.key,
    super.ref,
  });

  @override
  State createState() => _FutureBuilderState<T, FutureBuilder<T>>();
}

final class _FutureBuilderState<T, U extends FutureBuilder<T>>
    extends State<U> {
  Object? _activeCallbackIdentity;
  late AsyncSnapshot<T> _snapshot;

  void _subscribe() {
    if (widget.future != null) {
      final callbackIdentity = Object();

      _activeCallbackIdentity = callbackIdentity;

      widget.future!.then<void>(
        (final T data) {
          if (_activeCallbackIdentity == callbackIdentity) {
            setState(() {
              _snapshot = AsyncSnapshot.withData(
                connectionState: ConnectionState.done,
                data: data,
              );
            });
          }
        },
        onError: (final Object error, final StackTrace stackTrace) {
          if (_activeCallbackIdentity == callbackIdentity) {
            setState(() {
              _snapshot = AsyncSnapshot.withError(
                connectionState: ConnectionState.done,
                error: error,
                stackTrace: stackTrace,
              );
            });
          }
        },
      );

      _snapshot = _snapshot.inConnectionState(ConnectionState.waiting);
    }
  }

  void _unsubscribe() => _activeCallbackIdentity = null;

  @override
  void initialize() {
    super.initialize();

    _snapshot = widget.initialData == null
        ? AsyncSnapshot.nothing()
        : AsyncSnapshot.withData(
            connectionState: ConnectionState.none,
            data: widget.initialData as T,
          );

    _subscribe();
  }

  @override
  void widgetDidUpdate(final U oldWidget) {
    super.widgetDidUpdate(oldWidget);

    if (widget.future != oldWidget.future) {
      if (_activeCallbackIdentity != null) {
        _unsubscribe();
        _snapshot = _snapshot.inConnectionState(ConnectionState.none);
      }

      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return widget.builder(context, _snapshot);
  }
}
