part 'channel.dart';

/// The [Channeler] class acts as a centralized event communication manager
/// for the complete application lifecycle. Developers can register channels,
/// subscribe listeners, emit events, and remove subscriptions without tightly
/// coupling unrelated application layers or manually passing references around.
class Channeler {
  /// Shared singleton instance responsible for maintaining all registered
  /// channels and listeners globally across the application lifecycle. Using
  /// a singleton guarantees that every feature communicates through the same
  /// centralized and synchronized event distribution system during execution.
  static final Channeler instance = Channeler._();

  /// Returns the globally shared singleton instance of the [Channeler]
  /// communication manager. This prevents accidental creation of multiple
  /// independent event systems and ensures all application events remain
  /// synchronized through one centralized communication infrastructure.
  factory Channeler() => instance;

  /// Private constructor preventing external object instantiation of the
  /// [Channeler] class. Since this system is designed to operate globally
  /// as a singleton communication manager, object creation must remain
  /// internally controlled and restricted to a single shared instance.
  Channeler._();

  /// Internal storage maintaining all initialized channels and their
  /// corresponding listener collections. Every channel name maps to a list
  /// of subscribed callbacks which are triggered whenever events are emitted
  /// using the matching communication topic throughout the application.
  final Map<String, List<Function>> _channels = {};

  /// Registers a new communication channel into the global [Channeler]
  /// infrastructure. Channels must always be initialized before they can
  /// receive subscriptions or events, helping developers maintain safer
  /// communication flows and detect invalid channel usage during development.
  void initialize<T>(Channel<T> channel) {
    assert(
      !_channels.containsKey(channel.name),
      'Channel "${channel.name}" is already initialized.',
    );

    _channels[channel.name] = [];
  }

  /// Registers a listener callback for the provided communication channel.
  /// This method requires the channel to be initialized beforehand otherwise
  /// an assertion error is thrown helping developers catch invalid event
  /// subscriptions early during application development and testing phases.
  void subscribe<T>(Channel<T> channel, ChannelerCallback<T> listener) {
    assert(
      _channels.containsKey(channel.name),
      'Channel "${channel.name}" is not initialized.',
    );

    _channels[channel.name]!.add(listener);
  }

  /// Emits new data to all listeners currently subscribed to the provided
  /// communication channel. The method validates that the channel exists
  /// before dispatching events, preventing accidental communication through
  /// invalid or forgotten channels during the application execution lifecycle.
  void ping<T>(Channel<T> channel, T? data) {
    assert(
      _channels.containsKey(channel.name),
      'Channel "${channel.name}" is not initialized.',
    );

    final listeners = _channels[channel.name]!;

    for (final listener in List<Function>.from(listeners)) {
      try {
        (listener as ChannelerCallback<T>).call(data);
      } catch (_) {
        /// Silently ignores invalid listener casting issues caused by
        /// incorrect generic registrations under the same communication
        /// channel during runtime execution inside the application.
      }
    }
  }

  /// Removes a previously registered listener from the specified channel.
  /// The method validates channel initialization before attempting removal
  /// which helps identify incorrect unsubscribe operations and prevents
  /// unintended listener management bugs during application development.
  void unsubscribe<T>(Channel<T> channel, ChannelerCallback<T> listener) {
    assert(
      _channels.containsKey(channel.name),
      'Channel "${channel.name}" is not initialized.',
    );

    final removed = _channels[channel.name]!.remove(listener);

    assert(removed, 'Listener was not subscribed to "${channel.name}".');
  }

  /// Completely removes an initialized communication channel together with
  /// every listener currently attached to it. This operation helps clean
  /// unused communication topics and prevents stale callback references
  /// from remaining alive unnecessarily inside the event infrastructure.
  void disposeChannel<T>(Channel<T> channel) {
    assert(
      _channels.containsKey(channel.name),
      'Channel "${channel.name}" is not initialized.',
    );

    _channels.remove(channel.name);
  }
}
