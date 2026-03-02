import 'package:flutter/material.dart';

const _stats = [
  {'label': 'Total Users', 'value': '24,531', 'sub': '↑ 12% this month'},
  {'label': 'Active Sessions', 'value': '1,847', 'sub': '↑ 8% today'},
  {'label': 'Avg. Response', 'value': '142ms', 'sub': '↓ 15% improvement'},
  {'label': 'Error Rate', 'value': '0.02%', 'sub': 'Within SLA'},
];

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats Overview')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          childAspectRatio: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _stats.length,
        itemBuilder: (context, i) {
          final s = _stats[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s['label'] as String,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(s['value'] as String,
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(s['sub'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: (s['sub'] as String).startsWith('↑')
                            ? Colors.green
                            : (s['sub'] as String).startsWith('↓')
                                ? Colors.orange
                                : null,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
