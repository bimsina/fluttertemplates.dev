import 'package:flutter/material.dart';

class _Integration {
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final bool connected;
  const _Integration(
      this.name, this.category, this.icon, this.color, this.connected);
}

class Integrations extends StatelessWidget {
  const Integrations({super.key});

  static const _items = [
    _Integration('Slack', 'Messaging', Icons.tag, Color(0xFF611F69), true),
    _Integration('GitHub', 'Dev tools', Icons.code, Color(0xFF24292E), true),
    _Integration(
        'Stripe', 'Payments', Icons.credit_card, Color(0xFF635BFF), false),
    _Integration(
        'Notion', 'Docs', Icons.description, Color(0xFF000000), false),
    _Integration('Zapier', 'Automation', Icons.bolt, Color(0xFFFF4A00), true),
    _Integration('Figma', 'Design', Icons.brush, Color(0xFFF24E1E), false),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Integrations')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: [
          for (final it in _items)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: it.color.withValues(alpha: 0.15),
                    child: Icon(it.icon, color: it.color),
                  ),
                  const Spacer(),
                  Text(it.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(it.category,
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: it.connected
                        ? OutlinedButton(
                            onPressed: () {},
                            child: const Text('Connected'))
                        : FilledButton(
                            onPressed: () {},
                            child: const Text('Connect')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
