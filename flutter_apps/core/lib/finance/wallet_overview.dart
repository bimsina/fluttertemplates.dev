import 'package:flutter/material.dart';

const _wallets = [
  {'name': 'Primary', 'balance': '\$12,450.00', 'color': Colors.blue},
  {'name': 'Savings', 'balance': '\$8,320.50', 'color': Colors.green},
  {'name': 'Travel', 'balance': '\$2,100.00', 'color': Colors.orange},
];

class WalletOverview extends StatelessWidget {
  const WalletOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Overview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('\$22,870.50',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._wallets.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (w['color'] as Color).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_balance_wallet,
                          color: w['color'] as Color),
                    ),
                    title: Text(w['name'] as String),
                    subtitle: Text(w['balance'] as String),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
