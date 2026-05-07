import 'package:flutter/material.dart';
import 'package:pinger/pingora/pingora_scope.dart';
import 'package:pinger/pingora/pingora_selector.dart';
import 'pingora_model_example.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flow 2b: PingoraScope — Scoped Lifecycle for Pingora Controllers
// ─────────────────────────────────────────────────────────────────────────────

/// Demonstrates [PingoraScope] — a widget that creates a [Pingora] instance
/// and automatically DISPOSES it when the widget is removed from the tree.
///
/// This is perfect for screen-level ViewModels: the controller lives exactly
/// as long as the screen is visible, and is cleaned up automatically.
///
/// Lifecycle:
///   1. [PingoraScope.create] factory is called ONCE during [initState]
///   2. The [Pingora] is exposed down the tree via [_PingoraInherited]
///   3. [PingoraScope.dispose] auto-calls [Pingora.dispose()] on cleanup
///
/// NOTE: Since [_PingoraInherited] is a private class in the pinger package,
/// external code accesses the scoped [Pingora] either by:
///   - Using a public InheritedWidget wrapper
///   - Passing the reference through constructors
///   - Using a Provider-like pattern
///
/// For simplicity, this example passes the Pingora reference directly.
class PingoraScopeExample extends StatefulWidget {
  const PingoraScopeExample({super.key});

  @override
  State<PingoraScopeExample> createState() => _PingoraScopeExampleState();
}

class _PingoraScopeExampleState extends State<PingoraScopeExample> {
  /// This Pingora will be created once and disposed when the widget leaves.
  final PingoraModelExample _model = PingoraModelExample();

  @override
  void dispose() {
    /// CRITICAL: dispose the Pingora when the widget is removed.
    /// This clears all listeners and prevents memory leaks.
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the subtree with PingoraScope.
    // PingoraScope handles create + auto-dispose for you.
    return PingoraScope<PingoraModelExample>(
      create: () => _model,
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('PingoraScope Demo'),
          ),
          body: const _CounterBody(),
          floatingActionButton: const _IncrementButton(),
        );
      }),
    );
  }
}

/// Shows the counter using [PingoraSelector] for optimized rebuilds.
class _CounterBody extends StatelessWidget {
  const _CounterBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Scoped Counter (auto-disposed):'),
          // PingoraSelector only rebuilds when `count` changes.
          PingoraSelector<PingoraModelExample, int>(
            listenable: (_) => _findModel(context),
            selector: (m) => m.count,
            builder: (ctx, value) => Text(
              '$value',
              style: Theme.of(ctx).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'The Pingora is DISPOSED automatically\nwhen the scope widget is removed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  PingoraModelExample _findModel(BuildContext context) {
    // Walk up to find the PingoraScope state and get its pingora.
    // In a real app, use a public InheritedWidget lookup.
    final scopeState = context.findAncestorStateOfType<
        _PingoraScopeExampleState>();
    assert(scopeState != null, 'PingoraScopeExample not found above');
    return scopeState!._model;
  }
}

class _IncrementButton extends StatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final scopeState = context.findAncestorStateOfType<
            _PingoraScopeExampleState>();
        scopeState!._model.increaseCounter();
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}
