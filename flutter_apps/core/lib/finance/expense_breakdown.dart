import 'package:flutter/material.dart';

const _expenses = [
  {'label': 'Food', 'amount': 420, 'color': Colors.orange},
  {'label': 'Transport', 'amount': 280, 'color': Colors.blue},
  {'label': 'Shopping', 'amount': 350, 'color': Colors.purple},
  {'label': 'Bills', 'amount': 520, 'color': Colors.green},
  {'label': 'Other', 'amount': 180, 'color': Colors.grey},
];

class ExpenseBreakdown extends StatelessWidget {
  const ExpenseBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final total = _expenses.fold<double>(0, (s, e) => s + (e['amount'] as int));
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Breakdown')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      expenses: _expenses,
                      total: total,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('\$${total.toStringAsFixed(0)} total',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                ..._expenses.map((e) {
                  final pct = (e['amount'] as int) / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: e['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(e['label'] as String),
                        ),
                        Text('\$${e['amount']}'),
                        const SizedBox(width: 8),
                        Text('${(pct * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, Object>> expenses;
  final double total;

  _DonutPainter({required this.expenses, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    var startAngle = -1.5708;

    for (final e in expenses) {
      final sweep = 2 * 3.14159 * (e['amount'] as int) / total;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()
        ..color = e['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
