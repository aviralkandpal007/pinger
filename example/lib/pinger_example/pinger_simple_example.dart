import 'package:flutter/material.dart';
import 'package:pinger/pinger.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flow 1a: Pinger — Manual Subscribe / Ping / Unsubscribe / Dispose
// ─────────────────────────────────────────────────────────────────────────────

/// A global [Pinger] that broadcasts [int] values to all its subscribers.
///
/// Think of [Pinger] as a lightweight radio station:
///   1. Listeners **subscribe** to hear when new data arrives.
///   2. The broadcaster **pings** new data to everyone listening.
///   3. Listeners **unsubscribe** when they no longer want updates.
///   4. The station **disposes** when it shuts down completely.
final Pinger<int> counterPinger = Pinger<int>();

/// Demonstrates that [Pinger] works outside widgets too —
/// any Dart class (service, repository, BLoC, etc.) can subscribe.
class LoggingService {
  final List<String> _logs = [];

  void startListening() {
    counterPinger.subscribe(_onCounterUpdate);
    debugPrint('LoggingService: subscribed');
  }

  void _onCounterUpdate(int? value) {
    _logs.add('Value: $value');
    debugPrint('LoggingService received: $value');
  }

  void stopListening() {
    counterPinger.unsubscribe(_onCounterUpdate);
    debugPrint('LoggingService: unsubscribed');
  }

  List<String> get logs => List.unmodifiable(_logs);
}

/// Widget that manually manages subscribe/unsubscribe lifecycle.
/// You MUST call [unsubscribe] in dispose() to prevent memory leaks!
class PingerSimpleExample extends StatefulWidget {
  const PingerSimpleExample({super.key});

  @override
  State<PingerSimpleExample> createState() => _PingerSimpleExampleState();
}

class _PingerSimpleExampleState extends State<PingerSimpleExample> {
  final LoggingService _service = LoggingService();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Subscribe to pinger updates
    counterPinger.subscribe(_onData);
    // Also subscribe from the non-widget service
    _service.startListening();
  }

  void _onData(int? value) {
    if (value != null && mounted) {
      setState(() => _counter = value);
    }
  }

  @override
  void dispose() {
    // CRITICAL: always unsubscribe to avoid memory leaks!
    counterPinger.unsubscribe(_onData);
    _service.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pinger — Manual Subscribe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counter (manual subscribe):'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const Text(
              'Open your debug console to see\nLoggingService output',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counterPinger.ping(_counter + 1),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
