import 'package:flutter/material.dart';

const _sleepData = [
  {'day': 'Mon', 'hours': 7.5},
  {'day': 'Tue', 'hours': 6.5},
  {'day': 'Wed', 'hours': 8.0},
  {'day': 'Thu', 'hours': 7.0},
  {'day': 'Fri', 'hours': 5.5},
  {'day': 'Sat', 'hours': 9.0},
  {'day': 'Sun', 'hours': 8.5},
];

String _formatHours(double hours) {
  final minutes = (hours * 60).round();
  return '${minutes ~/ 60}h ${minutes % 60}m';
}

class SleepTracker extends StatelessWidget {
  const SleepTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHours = _sleepData.map((d) => d['hours'] as double).reduce((a, b) => a > b ? a : b);
    final avgHours = _sleepData.fold<double>(0, (s, d) => s + (d['hours'] as double)) / _sleepData.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('Last Night', style: Theme.of(context).textTheme.bodySmall),
                          Text(_formatHours(_sleepData.last['hours'] as double),
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Weekly Avg', style: Theme.of(context).textTheme.bodySmall),
                          Text('${avgHours.toStringAsFixed(1)}h',
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('This Week', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _sleepData.map((d) {
                  final h = d['hours'] as double;
                  final pct = h / (maxHours + 1);
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: pct,
                              child: Container(
                                width: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(d['day'] as String,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Set sleep goal'),
                subtitle: const Text('Recommended: 7-9 hours'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
