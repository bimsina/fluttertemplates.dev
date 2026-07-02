import 'package:flutter/material.dart';

class _Usage {
  final String label;
  final double kwh;
  final IconData icon;
  const _Usage(this.label, this.kwh, this.icon);
}

class EnergyUsage extends StatelessWidget {
  const EnergyUsage({super.key});

  static const _week = [8.2, 6.4, 9.1, 7.0, 10.4, 5.8, 6.9];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _breakdown = [
    _Usage('Heating', 42, Icons.thermostat),
    _Usage('Kitchen', 26, Icons.kitchen),
    _Usage('Lighting', 18, Icons.lightbulb_outline),
    _Usage('Other', 14, Icons.bolt),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxVal = _week.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Energy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This week',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('53.8 kWh',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('≈ \$12.40 · 8% less than last week',
                      style: TextStyle(color: Colors.green)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _week.length; i++)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 22,
                                height: 110 * (_week[i] / maxVal),
                                decoration: BoxDecoration(
                                  color: i == 4
                                      ? scheme.primary
                                      : scheme.primary
                                          .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(_days[i],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Breakdown',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final u in _breakdown)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(u.icon, color: scheme.primary),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: Text(u.label)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: u.kwh / 100,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${u.kwh.round()}%'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
