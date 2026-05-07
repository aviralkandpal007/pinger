part of 'channeler.dart';

/// Signature used for every listener registered inside the [Channeler]
/// communication system. Whenever a matching event is emitted on a channel,
/// all callbacks subscribed to that channel receive the latest emitted value
/// allowing reactive communication between completely independent components.
typedef ChannelerCallback<T> = void Function(T? value);

/// Represents a strongly typed communication topic inside the global
/// [Channeler] event system. Every channel contains a unique identifier
/// and a generic type definition which helps maintain safer communication
/// between widgets, services, repositories, controllers, and application logic.
class Channel<T> {
  /// Creates a strongly typed channel using the provided unique string name.
  /// This channel instance can later be registered into the [Channeler]
  /// system and then used throughout the application for publishing and
  /// subscribing to events associated with this communication topic.
  const Channel(this.name);

  /// Unique identifier used internally for locating and managing listeners
  /// belonging to the same communication topic. Multiple parts of the
  /// application can subscribe to the same channel and receive synchronized
  /// updates whenever events are emitted through the [Channeler] singleton.
  final String name;
}

///
extension ChannelerExtension on BuildContext {

  event(){

  }

}