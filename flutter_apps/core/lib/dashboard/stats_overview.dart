import 'dart:math';

import 'package:flutter/material.dart';

const _stats = [
  {'label': 'Total Users', 'value': '24,531', 'sub': '↑ 12% this month', 'status': 'good'},
  {'label': 'Active Sessions', 'value': '1,847', 'sub': '↑ 8% today', 'status': 'good'},
  {'label': 'Avg. Response', 'value': '142ms', 'sub': '↓ 15% improvement', 'status': 'good'},
  {'label': 'Error Rate', 'value': '0.02%', 'sub': 'Within SLA'},
];

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width > 600 ? 2 : 1;
    final tileWidth = (width - 32 - 16 * (columns - 1)) / columns;
    // Two-to-one tiles, unless the three text lines need more height. The 56
    // covers padding and card margin, and the 76 is the text at normal scale.
    final minHeight = 56 + MediaQuery.textScalerOf(context).scale(76);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats Overview')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: max(tileWidth / 2, minHeight),
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
                        color: switch (s['status']) {
                          'good' => Colors.green,
                          'bad' => Colors.orange,
                          _ => null,
                        },
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
