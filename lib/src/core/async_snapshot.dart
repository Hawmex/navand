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
