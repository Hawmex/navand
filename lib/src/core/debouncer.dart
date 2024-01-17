part of '../core.dart';

/// Debounces multiple tasks by running only the last one using
/// [scheduleMicrotask].
final class Debouncer {
  Object? _latestTaskIdentity;

  /// Schedules running the given [task].
  void scheduleTask(final void Function() task) {
    final currentTaskIdentity = Object();

    _latestTaskIdentity = currentTaskIdentity;

    scheduleMicrotask(() {
      if (_latestTaskIdentity == currentTaskIdentity) task();
    });
  }
}
