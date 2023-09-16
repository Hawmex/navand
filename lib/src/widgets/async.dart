part of widgets;

/// The connection state of an [AsyncSnapshot].
enum ConnectionState {
  none,
  waiting,
  active,
  done,
}

/// An immutable representation of the most recent interaction with an
/// asynchronous computation.
final class AsyncSnapshot<T> {
  final ConnectionState connectionState;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const AsyncSnapshot._({
    required this.connectionState,
    this.data,
    this.error,
    this.stackTrace,
  });

  /// Creates a new [AsyncSnapshot] with [ConnectionState.none].
  factory AsyncSnapshot.nothing() {
    return const AsyncSnapshot._(
      connectionState: ConnectionState.none,
    );
  }

  /// Creates a new [AsyncSnapshot] with [ConnectionState.waiting].
  factory AsyncSnapshot.waiting() {
    return const AsyncSnapshot._(
      connectionState: ConnectionState.waiting,
    );
  }

  /// Creates a new [AsyncSnapshot] with [connectionState] and [data].
  factory AsyncSnapshot.withData({
    required final ConnectionState connectionState,
    required final T data,
  }) {
    return AsyncSnapshot._(
      connectionState: connectionState,
      data: data,
    );
  }

  /// Creates a new [AsyncSnapshot] with [connectionState], [error], and
  /// [stackTrace].
  factory AsyncSnapshot.withError({
    required final ConnectionState connectionState,
    required final Object error,
    final StackTrace stackTrace = StackTrace.empty,
  }) {
    return AsyncSnapshot._(
      connectionState: connectionState,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Whether this [AsyncSnapshot] has data.
  bool get hasData => data != null;

  /// Whether this [AsyncSnapshot] has an error.
  bool get hasError => error != null;

  /// Returns the [data]. An error is thrown if [data] is `null`.
  T get requireData {
    if (hasData) return data!;
    if (hasError) Error.throwWithStackTrace(error!, stackTrace!);

    throw StateError('Snapshot has neither data nor error.');
  }

  /// Returns a copy of the current [AsyncSnapshot] with the given
  /// [connectionState].
  AsyncSnapshot<T> inConnectionState(final ConnectionState connectionState) {
    return AsyncSnapshot._(
      connectionState: connectionState,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// The type of the builder function used in async builders such as
/// [StreamBuilder] and [FutureBuilder].
typedef AsyncWidgetBuilder<T> = Widget Function(
  BuildContext context,
  AsyncSnapshot<T> snapshot,
);

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

// A [Widget] that is rebuilt with the latest snapshot of a [Stream].
final class StreamBuilder<T> extends StatefulWidget {
  final AsyncWidgetBuilder<T> builder;
  final Stream<T>? stream;
  final T? initialData;

  /// Creates a new [StreamBuilder].
  const StreamBuilder(
    this.builder, {
    this.stream,
    this.initialData,
    super.key,
    super.ref,
  });

  @override
  State createState() => _StreamBuilderState<T, StreamBuilder<T>>();
}

final class _StreamBuilderState<T, U extends StreamBuilder<T>>
    extends State<U> {
  StreamSubscription<T>? _subscription;
  late AsyncSnapshot<T> _snapshot;

  void _subscribe() {
    if (widget.stream != null) {
      _subscription = widget.stream!.listen(
        (final T data) {
          setState(() {
            _snapshot = AsyncSnapshot.withData(
              connectionState: ConnectionState.active,
              data: data,
            );
          });
        },
        onError: (final Object error, final StackTrace stackTrace) {
          setState(() {
            _snapshot = AsyncSnapshot.withError(
              connectionState: ConnectionState.active,
              error: error,
              stackTrace: stackTrace,
            );
          });
        },
        onDone: () {
          setState(() {
            _snapshot = _snapshot.inConnectionState(ConnectionState.done);
          });
        },
      );

      _snapshot = _snapshot.inConnectionState(ConnectionState.waiting);
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
  }

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

    if (widget.stream != oldWidget.stream) {
      if (_subscription != null) {
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
