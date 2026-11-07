import 'package:flutter/material.dart';

class _Kpi {
  final String title;
  final double value;
  final double target;
  final String prefix;
  final String suffix;
  final int decimals;
  final bool higherIsBetter;

  const _Kpi(
    this.title,
    this.value,
    this.target, {
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.higherIsBetter = true,
  });

  String format(double number) =>
      '$prefix${number.toStringAsFixed(decimals)}$suffix';

  double get percentVsTarget => (value - target) / target * 100;

  bool get isGood => higherIsBetter ? value >= target : value <= target;

  double get progress =>
      (higherIsBetter ? value / target : target / value).clamp(0.0, 1.0);
}

const _kpis = [
  _Kpi('Revenue', 124.5, 120, prefix: '\$', suffix: 'K', decimals: 1),
  _Kpi('Conversion', 3.2, 3.0, suffix: '%', decimals: 1),
  _Kpi('Churn', 1.8, 2.0, suffix: '%', decimals: 1, higherIsBetter: false),
  _Kpi('NPS', 72, 70),
];

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KPI Cards')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _kpis.map((k) {
          final percent = k.percentVsTarget;
          final sign = percent >= 0 ? '+' : '';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(k.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Icon(
                        percent >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: k.isGood ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(k.format(k.value),
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    'Target: ${k.format(k.target)} • '
                    '$sign${percent.toStringAsFixed(1)}% vs target',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: k.progress,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
