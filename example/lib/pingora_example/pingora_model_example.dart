import 'dart:developer';
import 'package:pinger/pingora.dart';

/// A concrete [Pingora] model that represents a counter.
///
/// Extending [Pingora] gives this class the superpower to notify listeners
/// (widgets, services, etc.) whenever its state changes via the [ping()]
/// method. This is the foundation of the ViewModel / Controller pattern
/// provided by the pinger package.
class PingoraModelExample extends Pingora {
  /// The current count value. Any widget subscribed to this model will
  /// receive updates whenever this value changes.
  int count = 0;

  /// Increments the counter, logs the new value, and [ping()]s all
  /// registered listeners to trigger UI rebuilds.
  void increaseCounter() {
    count++;
    log('Count Increased $count');
    ping();
  }
}
