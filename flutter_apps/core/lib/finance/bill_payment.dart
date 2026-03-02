import 'package:flutter/material.dart';

const _bills = [
  {'name': 'Electric', 'amount': '\$85', 'due': 'Mar 5', 'paid': false},
  {'name': 'Internet', 'amount': '\$45', 'due': 'Mar 8', 'paid': true},
  {'name': 'Water', 'amount': '\$62', 'due': 'Mar 10', 'paid': false},
  {'name': 'Phone', 'amount': '\$120', 'due': 'Mar 15', 'paid': false},
];

class BillPayment extends StatelessWidget {
  const BillPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Due This Month',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text('\$312',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  FilledButton(onPressed: () {}, child: const Text('Pay All')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._bills.map((b) => Card(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long),
                  ),
                  title: Text(b['name'] as String),
                  subtitle: Text('Due ${b['due']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(b['amount'] as String,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 8),
                      if (b['paid'] as bool)
                        Icon(Icons.check_circle, color: Colors.green, size: 24)
                      else
                        FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Pay')),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
