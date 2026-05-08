import 'package:flutter/material.dart';
import 'package:pinger/channeler/channeler.dart';
import 'package:pinger/channeler_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flow 3: Channeler — Global Event Bus for Decoupled Communication
// ─────────────────────────────────────────────────────────────────────────────

/// Define your communication channels as typed [Channel] constants.
/// Each channel has a unique [name] and a generic type [T] for the payload.
///
/// Think of channels as radio frequencies:
///   - Anyone can broadcast on a frequency
///   - Anyone can listen on a frequency
///   - The sender and receiver never need to know about each other
class AppChannels {
  /// Channel for theme change events (payload: theme name)
  static const themeChanged = Channel<String>('theme_changed');

  /// Channel for user notification events (payload: notification message)
  static const notification = Channel<String>('notification');

  /// Channel for counter events (payload: int value)
  static const counter = Channel<int>('app_counter');
}

/// Demonstrates the [Channeler] singleton — a global event bus that lets
/// completely decoupled parts of your app communicate without direct references.
///
/// Key concepts:
///   1. [Channeler.initialize] — register a channel before using it
///   2. [Channeler.subscribe] — listen for events on a channel
///   3. [Channeler.ping] — emit data to all listeners on a channel
///   4. [Channeler.unsubscribe] — remove a specific listener
///   5. [Channeler.disposeChannel] — remove a channel + all its listeners
///
/// The [ChannelerExtension] on [BuildContext] provides convenient access:
///   - `context.channeler` — get the singleton
///   - `context.initChannel(...)` — initialize
///   - `context.subscribeChannel(...)` — subscribe
///   - `context.pingChannel(...)` — emit
///   - `context.unsubscribeChannel(...)` — unsubscribe
///   - `context.disposeChannel(...)` — dispose channel
class ChannelerExample extends StatefulWidget {
  const ChannelerExample({super.key});

  @override
  State<ChannelerExample> createState() => _ChannelerExampleState();
}

class _ChannelerExampleState extends State<ChannelerExample> {
  final Channeler _channeler = Channeler();
  String _lastNotification = 'No notifications yet';

  @override
  void initState() {
    super.initState();


    // Step 2: Subscribe to channels.
    // These listeners are completely decoupled from the senders.
    _channeler.subscribe(AppChannels.notification, _onNotification);
    _channeler.subscribe(AppChannels.counter, _onCounterUpdate);
  }

  void _onNotification(String? message) {
    if (message != null && mounted) {
      setState(() => _lastNotification = message);
    }
  }

  void _onCounterUpdate(int? value) {
    debugPrint('Channeler received counter: $value');
  }

  @override
  void dispose() {
    // Step 4: Unsubscribe listeners to prevent memory leaks.
    _channeler.unsubscribe(AppChannels.notification, _onNotification);
    _channeler.unsubscribe(AppChannels.counter, _onCounterUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using the context extension for variety:
    // context.channeler is the same singleton as Channeler()
    final chan = context.channeler;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Channeler — Event Bus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Last Notification:'),
            const SizedBox(height: 8),
            Text(
              _lastNotification,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Step 3: Ping data to all notification listeners.
                chan.ping(
                  AppChannels.notification,
                  'Button pressed at ${DateTime.now().second}s',
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Ping Notification'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Ping to counter channel (received by _onCounterUpdate)
                chan.ping(AppChannels.counter, 42);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pinged 42 to counter channel'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Ping Counter (42)'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Channels enable completely decoupled\ncommunication across your app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
