import 'package:flutter/material.dart';
import 'package:pinger/pingora.dart';
import 'pinger_example/pinger_example.dart';
import 'pingora_example/pingora_example.dart';
import 'channeler_example/channeler_example.dart';
import 'pingora_example/pingora_model_example.dart';

void main() {
  runApp(const PingerExampleApp());
}

/// Root application demonstrating all three state management flows.
///
/// Each flow is self-contained:
///   Flow 1 — Pinger + PingBuilder (simple pub/sub)
///   Flow 2 — PingoraScope + PingoraSelector + context.pingora() (ViewModel)
///   Flow 3 — Channeler (global event bus)
class PingerExampleApp extends StatelessWidget {
  const PingerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinger Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleMenu(),
    );
  }
}

/// Main menu that navigates to each example flow.
class ExampleMenu extends StatelessWidget {
  const ExampleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinger — State Management'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Choose a flow to explore:',
              style: theme.textTheme.titleMedium,
            ),
          ),

          // ── Flow 1: Pinger + PingBuilder ──
          _FlowCard(
            icon: Icons.notifications_active,
            title: 'Flow 1: Pinger + PingBuilder',
            subtitle:
                'Simple subscribe/ping/unsubscribe + PingBuilder auto-lifecycle. '
                'Shows both manual and automatic approaches side by side.',
            onTap: () => _push(context, const PingerExample()),
          ),
          const SizedBox(height: 12),

          // ── Flow 2: Pingora (Scope + Selector + ctx) ──
          _FlowCard(
            icon: Icons.model_training,
            title: 'Flow 2: Pingora (Scope + Selector)',
            subtitle:
                'PingoraScope auto-creates/disposes a ViewModel. '
                'PingoraSelector rebuilds only on selected state. '
                'context.pingora<T>() provides clean access.',
            onTap: () => _push(
              context,
              PingoraScope(
                create: () => PingoraModelExample(),
                child: const PingoraExample(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Flow 3: Channeler ──
          _FlowCard(
            icon: Icons.hub,
            title: 'Flow 3: Channeler (Event Bus)',
            subtitle:
                'Decoupled global event bus with typed channels. '
                'Initialize, subscribe, ping, and unsubscribe across '
                'completely independent parts of your app.',
            onTap: () => _push(context, const ChannelerExample()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

/// Tappable card for navigating to a flow example.
class _FlowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FlowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
