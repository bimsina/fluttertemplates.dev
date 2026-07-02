import 'package:flutter/material.dart';

class _Turn {
  final IconData icon;
  final String instruction;
  final String distance;
  const _Turn(this.icon, this.instruction, this.distance);
}

class Directions extends StatelessWidget {
  const Directions({super.key});

  static const _turns = [
    _Turn(Icons.straight, 'Head north on Market St', '400 m'),
    _Turn(Icons.turn_right, 'Turn right onto 5th Ave', '1.2 km'),
    _Turn(Icons.turn_slight_left, 'Keep left toward Riverside', '600 m'),
    _Turn(Icons.turn_left, 'Turn left onto Harbour Lane', '250 m'),
    _Turn(Icons.place, 'Arrive at destination', ''),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Directions')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: scheme.primary,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('18 min',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold)),
                Text('4.6 km · Fastest route, light traffic',
                    style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                          onPressed: () {},
                          icon: const Icon(Icons.navigation),
                          label: const Text('Start')),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onPrimary,
                          side: BorderSide(
                              color: scheme.onPrimary
                                  .withValues(alpha: 0.5))),
                      child: const Text('Steps'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _turns.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = _turns[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(t.icon, color: scheme.onPrimaryContainer),
                  ),
                  title: Text(t.instruction),
                  trailing: Text(t.distance,
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
