import 'package:flutter/material.dart';
import 'package:pinger/pinger.dart';
import 'package:pinger/builders.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flow 1b: PingBuilder — Automatic subscribe/unsubscribe in widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Another [Pinger] instance so this example is self-contained.
final Pinger<int> autoCounterPinger = Pinger<int>();

/// Demonstrates [PingBuilder] — a widget that automatically subscribes to a
/// [Pinger] and rebuilds when new data arrives. No manual subscribe/unsubscribe
/// is needed — [PingBuilder] handles the lifecycle for you.
///
/// [PingBuilder] is a [StatelessWidget] that internally delegates to a
/// stateful widget which:
///   1. Subscribes to the [Pinger] in [State.initState]
///   2. Calls [setState] whenever a new value is pinged
///   3. Unsubscribes automatically in [State.dispose]
///
/// Required parameters:
/// - [pinger]: The [Pinger<T>] instance to listen to
/// - [builder]: A [Widget Function(BuildContext, T?)] that builds UI with the value
///
/// Optional:
/// - [initialData]: A default value shown until the first ping arrives
class PingerBuilderExample extends StatelessWidget {
  const PingerBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('PingBuilder — Auto Subscribe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counter (PingBuilder auto-managed):'),
            // PingBuilder handles subscribe/unsubscribe internally!
            // No need for StatefulWidget + initState/dispose boilerplate.
            PingBuilder<int>(
              pinger: autoCounterPinger,
              initialData: 0, // shown until the first ping
              builder: (context, value) {
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'PingBuilder auto-cleans when removed from tree',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final current = autoCounterPinger.data ?? 0;
          autoCounterPinger.ping(current + 1);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
