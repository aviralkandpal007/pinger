import 'package:flutter/material.dart';
import 'pinger_example/pinger_simple_example.dart';
import 'pinger_example/pinger_builder_example.dart';
import 'pingora_example/pingora_selector_example.dart';
import 'pingora_example/pingora_scope_example.dart';
import 'channeler_example/channeler_example.dart';

void main() {
  runApp(const PingerExampleApp());
}

/// Root application demonstrating all three pinger state management flows.
///
/// Each example is self-contained and showcases a different aspect
/// of the pinger package's capabilities.
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
          // ── Header ──
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Choose a flow to explore:',
              style: theme.textTheme.titleMedium,
            ),
          ),

          // ── Flow 1: Pinger ──
          _SectionHeader(title: 'Flow 1: Pinger (Pub/Sub)', icon: Icons.notifications_active),
          _ExampleCard(
            title: 'Manual Subscribe / Unsubscribe',
            subtitle: 'Subscribe, ping, unsubscribe, and dispose manually. Also shows '
                'that Pinger works from non-widget classes (services).',
            onTap: () => _push(context, const PingerSimpleExample()),
          ),
          _ExampleCard(
            title: 'PingBuilder (Auto Subscribe)',
            subtitle: 'PingBuilder handles subscribe/unsubscribe lifecycle automatically. '
                'No StatefulWidget boilerplate needed.',
            onTap: () => _push(context, const PingerBuilderExample()),
          ),
          const SizedBox(height: 16),

          // ── Flow 2: Pingora ──
          _SectionHeader(title: 'Flow 2: Pingora (ViewModel)', icon: Icons.model_training),
          _ExampleCard(
            title: 'PingoraSelector',
            subtitle: 'Optimized widget that rebuilds only when a selected portion '
                'of state changes. Ideal for performance-sensitive UIs.',
            onTap: () => _push(context, const PingoraSelectorExample()),
          ),
          _ExampleCard(
            title: 'PingoraScope',
            subtitle: 'Scopes a Pingora controller lifecycle to a widget subtree. '
                'Auto-creates and auto-disposes the controller.',
            onTap: () => _push(context, const PingoraScopeExample()),
          ),
          const SizedBox(height: 16),

          // ── Flow 3: Channeler ──
          _SectionHeader(title: 'Flow 3: Channeler (Event Bus)', icon: Icons.hub),
          _ExampleCard(
            title: 'Global Event Bus',
            subtitle: 'Decoupled communication via typed channels. Perfect for '
                'cross-cutting concerns like navigation, theming, notifications.',
            onTap: () => _push(context, const ChannelerExample()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

/// Styled section header.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Tappable card for navigation.
class _ExampleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
