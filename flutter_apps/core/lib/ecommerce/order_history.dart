import 'package:flutter/material.dart';

const _orders = [
  {'id': '12345', 'status': 'Delivered', 'date': 'Dec 1, 2024'},
  {'id': '12344', 'status': 'Shipped', 'date': 'Nov 28, 2024'},
  {'id': '12343', 'status': 'Processing', 'date': 'Nov 25, 2024'},
];

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, i) {
          final o = _orders[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ExpansionTile(
              title: Text('Order #${o['id']}'),
              subtitle: Text('${o['date']}'),
              trailing: Chip(
                label: Text(o['status'] as String),
                backgroundColor: _statusColor(o['status'] as String),
              ),
              onExpansionChanged: (v) => setState(() {
                if (v) {
                  _expanded.add(o['id'] as String);
                } else {
                  _expanded.remove(o['id']);
                }
              }),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item 1 - \$29.99 x 1'),
                      Text('Item 2 - \$15.99 x 2'),
                      const SizedBox(height: 8),
                      Text(
                        'Total: \$61.97',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color? _statusColor(String s) {
    if (s == 'Delivered') return Colors.green.withValues(alpha: 0.3);
    if (s == 'Shipped') return Colors.blue.withValues(alpha: 0.3);
    return Colors.orange.withValues(alpha: 0.3);
  }
}
