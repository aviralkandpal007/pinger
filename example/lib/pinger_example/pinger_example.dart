import 'package:flutter/material.dart';
import 'package:pinger/pinger.dart';
import 'package:pinger/builders.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flow 1: Pinger + PingBuilder — Simple Pub/Sub State Management
// ─────────────────────────────────────────────────────────────────────────────

/// A [Pinger] broadcasts typed data to all its subscribers.
///
/// ## Manual API (subscribe / ping / unsubscribe / dispose)
/// ```dart
/// final pinger = Pinger<int>();
/// pinger.subscribe((value) => print(value));
/// pinger.ping(42);           // notifies all subscribers
/// pinger.unsubscribe(listener);
/// pinger.dispose();          // permanently shuts down
/// ```
///
/// ## PingBuilder (auto lifecycle)
/// ```dart
/// PingBuilder<int>(
///   pinger: pinger,
///   builder: (context, value) => Text('$value'),
/// )
/// ```
final Pinger<int> counterPinger = Pinger<int>();

/// A service class (non-widget) that subscribes to the pinger.
/// This proves [Pinger] works outside widgets — any Dart code can listen.
class LoggingService {
  final List<String> _logs = [];

  void startListening() {
    counterPinger.subscribe(_logUpdate);
  }

  void _logUpdate(int? value) {
    _logs.add('$value');
    debugPrint('LoggingService: $value');
  }

  void stopListening() {
    counterPinger.unsubscribe(_logUpdate);
  }
}

/// Combines both manual subscribe/ping/unsubscribe AND PingBuilder auto-mode
/// so you can compare the two approaches side by side.
class PingerExample extends StatefulWidget {
  const PingerExample({super.key});

  @override
  State<PingerExample> createState() => _PingerExampleState();
}

class _PingerExampleState extends State<PingerExample> {
  final LoggingService _service = LoggingService();
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    // ── Manual subscribe ──
    counterPinger.subscribe(_onData);

    // ── Non-widget service subscribe ──
    _service.startListening();
  }

  void _onData(int? value) {
    if (value != null && mounted) {
      setState(() => _counter = value);
    }
  }

  @override
  void dispose() {
    // ── Must unsubscribe to prevent memory leaks ──
    counterPinger.unsubscribe(_onData);
    _service.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pinger + PingBuilder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Manual subscribe display ──
            const Text('Manual subscribe (setState):'),
            Text('$_counter',
                style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(height: 16),
            const Divider(indent: 48, endIndent: 48),
            const SizedBox(height: 16),

            // ── PingBuilder (auto subscribe/unsubscribe) ──
            const Text('PingBuilder (auto-managed):'),
            PingBuilder<int>(
              pinger: counterPinger,
              initialData: 0,
              builder: (context, value) => Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Both approaches listen to the SAME Pinger.\n'
              'PingBuilder handles subscribe/unsubscribe automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
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
