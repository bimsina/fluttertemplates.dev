import 'package:flutter/material.dart';

class _Meter {
  final String label;
  final int used;
  final int limit;
  final String unit;
  const _Meter(this.label, this.used, this.limit, this.unit);
}

class UsageDashboard extends StatelessWidget {
  const UsageDashboard({super.key});

  static const _meters = [
    _Meter('API requests', 82000, 100000, ''),
    _Meter('Storage', 38, 50, 'GB'),
    _Meter('Team seats', 9, 10, ''),
    _Meter('Automations', 1200, 2000, '/mo'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Usage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pro plan',
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold)),
                      Text('Renews Aug 1 · \$49/mo',
                          style: TextStyle(color: scheme.onPrimaryContainer)),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                      onPressed: () {}, child: const Text('Upgrade')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final m in _meters) _MeterTile(meter: m),
        ],
      ),
    );
  }
}

class _MeterTile extends StatelessWidget {
  final _Meter meter;
  const _MeterTile({required this.meter});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = meter.used / meter.limit;
    final near = ratio > 0.8;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(meter.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_fmt(meter.used)} / ${_fmt(meter.limit)}${meter.unit}',
                    style: TextStyle(
                        color: near ? scheme.error : scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                color: near ? scheme.error : scheme.primary,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k' : '$n';
}
