import 'package:flutter/widgets.dart';

import 'channeler/channeler.dart';

/// Extension added on top of Flutter's [BuildContext] class for providing
/// shorter and cleaner access to the global [Channeler] communication system.
/// These helper methods reduce repetitive singleton calls and make channel
/// subscriptions and event publishing significantly easier throughout widgets.
extension ChannelerExtension on BuildContext {
  /// Returns the globally shared singleton instance of the [Channeler]
  /// communication manager directly from the current widget context. This
  /// helper simplifies access to the centralized event infrastructure and
  /// avoids repeatedly calling the factory constructor manually everywhere.
  Channeler get channeler => Channeler();

  /// Initializes a new communication channel inside the global [Channeler]
  /// infrastructure using the current widget context. Channels must always
  /// be initialized before they can receive subscriptions or published
  /// events otherwise assertion errors will be triggered during execution.
  void initChannel<T>(List<Channel<T>> channels) {
    channeler.initialize(channels);
  }

  /// Registers a listener callback for the provided communication channel
  /// directly from the current widget context. This method simplifies event
  /// subscriptions inside widgets while still maintaining all validation
  /// and safety checks implemented internally by the [Channeler] system.
  void subscribeChannel<T>(Channel<T> channel, ChannelerCallback<T> listener) {
    channeler.subscribe(channel, listener);
  }

  /// Emits new data into the specified communication channel directly from
  /// the current widget context. Every listener subscribed to the matching
  /// channel receives the emitted payload allowing reactive communication
  /// between completely independent parts of the application architecture.
  void pingChannel<T>(Channel<T> channel, T? data) {
    channeler.ping(channel, data);
  }

  /// Removes a previously subscribed listener callback from the specified
  /// communication channel using the current widget context. This operation
  /// helps prevent memory leaks, duplicate callbacks, and unnecessary
  /// updates once widgets or services no longer require event listening.
  void unsubscribeChannel<T>(
    Channel<T> channel,
    ChannelerCallback<T> listener,
  ) {
    channeler.unsubscribe(channel, listener);
  }

  /// Completely removes an initialized communication channel together with
  /// every listener currently attached to it. This helper allows widgets
  /// and services to safely clean unused event topics directly from the
  /// current widget context without accessing the singleton manually.
  void disposeChannel<T>(Channel<T> channel) {
    channeler.disposeChannel(channel);
  }
}
