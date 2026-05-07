import 'package:flutter/cupertino.dart';

/// This the extensible class for a viewmodel or controller for a particular
/// page or screen. With the help of [Pingora]  we will manage all the state
/// of that particular class for which we have extended this viewmodel.
/// So what this does, in simpler terms when a class extends [Pingora], it
/// automatically enables a pinger within itself which helps the developer
/// to ping various states for the user which helps the user to directly track
/// and update the particular state for that widget which required UI updates
/// according to the data changes.
class Pingora {
  /// The [Pingora] is the base of the pingora class as this will ping required
  /// subscribers about the data updates.
  final List<VoidCallback> _listeners = [];

  bool _disposed = false;

  /// This will update the [Pingora] subscribers behind the scene and will update
  /// each time the [Pingora] pings via the [Pingora]
  void subscribe(VoidCallback listener){
    debugPrint('subscribe $listener');
    _listeners.add(listener);
  }

  /// This will remove the [Pingora] subscriber so the updates can be canceled
  void unsubscribe(VoidCallback listener){
    debugPrint('unsubscribe $listener');
    _listeners.remove(listener);
  }

  /// The method [ping] is basically taking a [Pingora] model as a model because
  /// [Pingora] can hold any type of data in its model.
  void ping() {
    debugPrint('calling ping');
    debugPrint('_listeners ${_listeners.length}');
    for (var listener in _listeners) {
      listener.call();
    }
  }

  /// The method [dispose] will remove all the listener in the pinger and will
  /// close any further pingora activity
  void dispose() {
    _listeners.clear();
    _disposed = true;
  }
}
