import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';

/// The base class for creating ViewModels / Controllers that can notify
/// listeners about state changes.
///
/// Extend this class to create a stateful controller, then use [subscribe]
/// to listen for updates, [ping] to notify all listeners, [unsubscribe] to
/// remove a listener, and [dispose] to permanently shut down the controller.
///
/// ```dart
/// class CounterModel extends Pingora {
///   int count = 0;
///
///   void increment() {
///     count++;
///     ping(); // notify all subscribers
///   }
/// }
/// ```
///
/// Once [dispose] is called, any further calls to [subscribe], [unsubscribe],
/// or [ping] will throw an [AssertionError] to catch bugs early.
class Pingora {
  final List<VoidCallback> _listeners = [];

  bool _disposed = false;

  Pingora() {
    developer.log(
      'Pingora<$runtimeType> initialized',
      name: 'pingora',
    );
  }

  /// Registers a listener that will be called every time [ping] is invoked.
  ///
  /// Throws an [AssertionError] if the [Pingora] has already been disposed.
  void subscribe(VoidCallback listener) {
    assert(
      !_disposed,
      AssertionError('Can not subscribe to a disposed Pingora'),
    );
    _listeners.add(listener);
    developer.log(
      'Pingora<$runtimeType> subscribed (listeners: ${_listeners.length})',
      name: 'pingora',
    );
  }

  /// Removes a previously registered listener.
  ///
  /// Throws an [AssertionError] if the [Pingora] has already been disposed
  /// or if the listener was never subscribed.
  void unsubscribe(VoidCallback listener) {
    assert(
      !_disposed,
      AssertionError('Can not unsubscribe from a disposed Pingora'),
    );
    final removed = _listeners.remove(listener);
    assert(removed, 'Tried to remove a listener that was not subscribed');
    developer.log(
      'Pingora<$runtimeType> unsubscribed (listeners: ${_listeners.length})',
      name: 'pingora',
    );
  }

  /// Notifies all currently subscribed listeners by calling each one.
  ///
  /// Throws an [AssertionError] if the [Pingora] has already been disposed.
  void ping() {
    assert(!_disposed, AssertionError('Can not ping on a disposed Pingora'));
    developer.log(
      'Pingora<$runtimeType> pinged (listeners: ${_listeners.length})',
      name: 'pingora',
    );
    for (var listener in _listeners) {
      listener.call();
    }
  }

  /// Permanently disables this [Pingora].
  ///
  /// Clears all listeners and sets the disposed flag so that any future
  /// calls to [subscribe], [unsubscribe], or [ping] will throw an error.
  void dispose() {
    developer.log(
      'Pingora<$runtimeType> disposed (listeners cleared: ${_listeners.length})',
      name: 'pingora',
    );
    _disposed = true;
    _listeners.clear();
  }
}
