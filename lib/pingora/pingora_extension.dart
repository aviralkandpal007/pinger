part of 'pingora_scope.dart';

/// Extension on [BuildContext] providing convenient access to [Pingora]
/// controllers that are scoped via [PingoraScope] ancestors in the widget tree.
///
/// ## Usage
///
/// ```dart
/// // Inside any widget that is a child of PingoraScope<CounterModel>:
///
/// // Get the model and subscribe to updates
/// final model = context.pingora<CounterModel>();
/// model.subscribe(_onUpdate);
///
/// // Trigger a ping to all listeners
/// model.increment();  // internally calls ping()
///
/// // Unsubscribe when done
/// model.unsubscribe(_onUpdate);
/// ```
extension PingoraExtension on BuildContext {
  /// Retrieves the nearest [Pingora] instance of type [T] from an ancestor
  /// [PingoraScope] in the widget tree.
  ///
  /// Once you have the instance, you can call any [Pingora] method directly:
  ///
  /// ```dart
  /// final model = context.pingora<CounterModel>();
  ///
  /// model.subscribe(listener);      // listen for state changes
  /// model.ping();                   // notify all listeners
  /// model.unsubscribe(listener);   // stop listening
  /// model.dispose();                // shut down permanently
  /// ```
  ///
  /// Throws an [AssertionError] if no matching [PingoraScope] is found above
  /// in the widget tree.
  T pingora<T extends Pingora>() {
    final inherited =
        dependOnInheritedWidgetOfExactType<_PingoraInherited<T>>();
    assert(
      inherited != null,
      'No PingoraScope<$T> found above in the widget tree. '
      'Ensure the widget is wrapped in a PingoraScope<$T>.',
    );
    return inherited!.pingora;
  }
}
