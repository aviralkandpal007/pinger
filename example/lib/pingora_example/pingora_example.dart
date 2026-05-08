import 'package:flutter/material.dart';
import 'package:pinger/pingora.dart';
import 'package:pinger/pingora/pingora_scope.dart';
import 'package:pinger/pingora/pingora_selector.dart';
import 'pingora_model_example.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flow 2: PingoraScope + PingoraSelector + context.pingora<T>()
//         ViewModel / Controller Pattern
// ─────────────────────────────────────────────────────────────────────────────

/// Demonstrates the complete Pingora workflow:
///
/// 1. [PingoraScope] wraps the widget tree — it creates the model ONCE and
///    automatically DISPOSES it when the scope is removed.
///
/// 2. Manual subscribe via `context.pingora<T>()` — registers a listener
///    on the scoped model. [unsubscribe] is called in [dispose].
///
/// 3. [PingoraSelector] — subscribes automatically and only rebuilds when
///    the selected state slice (count) changes.
class PingoraExample extends StatelessWidget {
  const PingoraExample({super.key});

  @override
  Widget build(BuildContext context) {
    // PingoraScope wraps the entire screen.
    // - create: called once per scope lifetime
    // - dispose: called automatically when the scope leaves the tree
    return PingoraScope<PingoraModelExample>(
      create: () => PingoraModelExample(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Pingora (Scope + Selector + ctx)'),
        ),
        body: const _CounterBody(),
        floatingActionButton: const _IncrementButton(),
      ),
    );
  }
}

/// A separate widget so [didChangeDependencies] runs after [PingoraScope]
/// has been mounted (the scope is built by the parent [PingoraExample]).
class _CounterBody extends StatefulWidget {
  const _CounterBody();

  @override
  State<_CounterBody> createState() => _CounterBodyState();
}

class _CounterBodyState extends State<_CounterBody> {
  int _count = 0;
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe once via the context extension.
    // This runs after PingoraScope is already mounted, so
    // context.pingora<T>() can find it via InheritedWidget lookup.
    if (!_subscribed) {
      _subscribed = true;
      context.pingora<PingoraModelExample>().subscribe(_onPing);
    }
  }

  void _onPing() {
    if (mounted) {
      setState(() {
        _count = context.pingora<PingoraModelExample>().count;
      });
    }
  }

  @override
  void dispose() {
    // Must unsubscribe to avoid memory leaks.
    // PingoraScope will dispose the model itself when it leaves the tree.
    if (_subscribed) {
      try {
        context.pingora<PingoraModelExample>().unsubscribe(_onPing);
      } catch (_) {
        // Ignore — scope may already be gone during teardown
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Via manual subscribe (setState) ──
          const Text('Manual subscribe via context.pingora():'),
          Text('$_count',
              style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: 16),
          const Divider(indent: 48, endIndent: 48),
          const SizedBox(height: 16),

          // ── Via PingoraSelector (auto lifecycle, fine-grained) ──
          const Text('PingoraSelector (auto-managed):'),
          PingoraSelector<PingoraModelExample, int>(
            listenable: (ctx) => ctx.pingora<PingoraModelExample>(),
            selector: (m) => m.count,
            builder: (ctx, value) => Text(
              '$value',
              style: Theme.of(ctx).textTheme.headlineMedium,
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'PingoraScope auto-creates and auto-disposes the model.\n'
            'PingoraSelector only rebuilds when the selected value changes.\n'
            'context.pingora<T>() retrieves the model from the scope.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _IncrementButton extends StatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          context.pingora<PingoraModelExample>().increaseCounter(),
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}
