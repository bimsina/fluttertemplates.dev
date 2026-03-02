import 'package:flutter/material.dart';

const _transactions = [
  {
    'merchant': 'Amazon',
    'amount': '-\$45.99',
    'date': 'Today',
    'icon': Icons.shopping_bag,
  },
  {
    'merchant': 'Starbucks',
    'amount': '-\$6.50',
    'date': 'Today',
    'icon': Icons.coffee,
  },
  {
    'merchant': 'Salary',
    'amount': '+\$3,500',
    'date': 'Yesterday',
    'icon': Icons.account_balance,
  },
  {
    'merchant': 'Uber',
    'amount': '-\$24.30',
    'date': 'Mar 1',
    'icon': Icons.directions_car,
  },
  {
    'merchant': 'Netflix',
    'amount': '-\$15.99',
    'date': 'Mar 1',
    'icon': Icons.movie,
  },
  {
    'merchant': 'Transfer',
    'amount': '+\$200',
    'date': 'Feb 28',
    'icon': Icons.swap_horiz,
  },
];

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final t = _transactions[i];
          final isCredit = (t['amount'] as String).startsWith('+');
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                t['icon'] as IconData,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(t['merchant'] as String),
            subtitle: Text(t['date'] as String),
            trailing: Text(
              t['amount'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isCredit
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
