/// The [PingerCallback] will be used as a data listening port for the other
/// non widget parts so that we can also subscribe to the [Pinger] updates in
/// any method to directly fetch the update as required.
typedef PingerCallback<T> = void Function(T? value);

/// This is a [Pinger] for extending the flutter state management for updating
/// the data in the flutter tree with help of the [Pinger] which will directly
/// can be listened in any ui [Widget] or any other functionality spots enhancing
/// the speed and communication between tree [Widgets].
class Pinger<T> {
  /// This dispose value will be checked to handle the data notifier if
  /// the value of this notifier is changed to [true] it will cancel all the
  /// incoming data notifications and stops the updates
  bool _disposed = false;

  /// Private [_data] will be used to only update the data from the the updates
  /// methods declared to keep the privacy in the class.
  T? _data;

  /// The [data] will be the [Pinger] current holding value that can be fetched
  /// when required by the widget and will be updated and sent to multiple
  /// notifiers when ever any update will be received to the [Pinger] object.
  T? get data => _data;

  /// This will maintain the [Pinger] subscriptions so that when the new data
  /// will came to the [Pinger] all the subscription listeners will get the
  /// updates directly without waiting for any UI/Widgets updates.
  final List<PingerCallback<T>> _pingerSubscriptions = [];

  /// The [subscribe] method add the subscription for the current [Pinger]
  /// class when we will subscribe to the current notifier for the updates
  /// if you subscribe to the the notifier it is mandatory to unsubscribe from
  /// the notifier if you are not disposing the notifier, that will help to
  /// unsubscribe single [PingerCallback]
  void subscribe(PingerCallback<T?> listener) {
    assert(
      !_disposed,
      AssertionError('Can not subscribe to a disposed Pinger'),
    );
    // this will add the listener to the list of the notifier subscription
    // which will update all the subscribed notifier
    _pingerSubscriptions.add(listener);
  }

  /// The [ping] method checks whether or not the new update contains the
  /// new data and can be updated correctly, you can pass the ping with
  /// [forcePing] bool value so that if the user wants the updates even
  /// if the data is same it can update
  void ping(T? data, {bool forcePing = false}) {
    assert(!_disposed, AssertionError('Can not ping on a disposed Pinger'));
    // check the force ping value
    if (forcePing || _data != data) {
      // this will send the data to each of the updates
      for (var e in _pingerSubscriptions) {
        e.call(data);
      }
    }
  }

  /// The [unsubscribe] method removes the subscription for the current [Pinger]
  /// class when we will remove to the current notifier for the updates
  /// this will help to remove the unwanted listeners from [PingerCallback]
  void unsubscribe(PingerCallback<T?> listener) {
    // check if already disposed if disposed throw the assertion error
    assert(
      !_disposed,
      throw AssertionError('Can not unsubscribe from a disposed Pinger'),
    );
    // if not remove the topic we want to unsubscribe
    bool removed = _pingerSubscriptions.remove(listener);
    // if not removed than throw the error that no listener was there
    assert(removed, 'Tried to dispose a listener that was not subscribed');
  }

  /// The [dispose] function once called will remove all the notifier
  /// subscription at once and will disable the notifier functionality
  /// after disposing the [Pinger] any ping to the [data] will not update
  /// any widgets or any subscription
  void dispose(PingerCallback<T> listener) {
    _disposed = true;
    _pingerSubscriptions.clear();
  }
}
