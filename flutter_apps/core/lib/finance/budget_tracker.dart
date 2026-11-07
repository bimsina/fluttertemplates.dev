import 'package:flutter/material.dart';

const _categories = [
  {'name': 'Food', 'spent': 320, 'limit': 500, 'color': Colors.orange},
  {'name': 'Transport', 'spent': 180, 'limit': 200, 'color': Colors.blue},
  {'name': 'Shopping', 'spent': 450, 'limit': 400, 'color': Colors.purple},
  {'name': 'Entertainment', 'spent': 75, 'limit': 150, 'color': Colors.green},
];

String _usd(int amount) {
  final digits = amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => ',',
  );
  return '\$$digits';
}

class BudgetTracker extends StatelessWidget {
  const BudgetTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final totalSpent = _categories.fold<int>(
      0,
      (sum, c) => sum + (c['spent'] as int),
    );
    final totalLimit = _categories.fold<int>(
      0,
      (sum, c) => sum + (c['limit'] as int),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Monthly Budget',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_usd(totalSpent)} / ${_usd(totalLimit)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (totalSpent / totalLimit).clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ..._categories.map((c) {
            final spent = c['spent'] as int;
            final limit = c['limit'] as int;
            final pct = spent / limit;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap stacks these when large text can't fit one line.
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              c['name'] as String,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '\$$spent / \$$limit',
                              style: TextStyle(
                                color: pct > 1 ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: pct > 1 ? 1 : pct,
                        backgroundColor: (c['color'] as Color).withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation(
                          pct > 1 ? Colors.red : c['color'] as Color,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
