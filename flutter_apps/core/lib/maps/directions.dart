import 'package:flutter/material.dart';

class _Turn {
  final IconData icon;
  final String instruction;
  final int meters;
  const _Turn(this.icon, this.instruction, this.meters);
}

String _formatDistance(int meters) {
  if (meters == 0) return '';
  if (meters < 1000) return '$meters m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

class Directions extends StatelessWidget {
  const Directions({super.key});

  static const _turns = [
    _Turn(Icons.straight, 'Head north on Market St', 800),
    _Turn(Icons.turn_right, 'Turn right onto 5th Ave', 2100),
    _Turn(Icons.turn_slight_left, 'Keep left toward Riverside', 1200),
    _Turn(Icons.turn_left, 'Turn left onto Harbour Lane', 500),
    _Turn(Icons.place, 'Arrive at destination', 0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final totalMeters = _turns.fold(0, (sum, turn) => sum + turn.meters);

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
                Text(
                    '${_formatDistance(totalMeters)} · Fastest route, light traffic',
                    style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                          onPressed: () => _showDemo(context, 'Start (demo)'),
                          icon: const Icon(Icons.navigation),
                          label: const Text('Start')),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => _showDemo(context, 'Steps (demo)'),
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
                  trailing: Text(_formatDistance(t.meters),
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

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
