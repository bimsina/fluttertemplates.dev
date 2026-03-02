import 'package:flutter/material.dart';

const _kpis = [
  {'title': 'Revenue', 'value': '\$124.5K', 'target': '\$120K', 'trend': 'up', 'pct': 12},
  {'title': 'Conversion', 'value': '3.2%', 'target': '3.0%', 'trend': 'up', 'pct': 6},
  {'title': 'Churn', 'value': '1.8%', 'target': '2.0%', 'trend': 'down', 'pct': 10},
  {'title': 'NPS', 'value': '72', 'target': '70', 'trend': 'up', 'pct': 3},
];

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KPI Cards')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _kpis.map((k) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(k['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium),
                    Icon(
                      (k['trend'] as String) == 'up'
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: (k['trend'] as String) == 'up'
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(k['value'] as String,
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('Target: ${k['target']} • ${k['pct']}% vs target',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ((k['pct'] as int) + 50) / 100,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
