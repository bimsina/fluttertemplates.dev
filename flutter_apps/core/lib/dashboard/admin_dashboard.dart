import 'package:flutter/material.dart';

const _metrics = [
  {'label': 'Users', 'value': '12,847', 'change': '+12%', 'icon': Icons.people},
  {'label': 'Revenue', 'value': '\$48.2K', 'change': '+8%', 'icon': Icons.attach_money},
  {'label': 'Orders', 'value': '1,234', 'change': '-3%', 'icon': Icons.shopping_cart},
  {'label': 'Active', 'value': '89%', 'change': '+2%', 'icon': Icons.trending_up},
];

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final count = constraints.maxWidth > 600 ? 4 : 2;
                const spacing = 12.0;
                final tileWidth =
                    ((constraints.maxWidth - spacing * (count - 1)) / count)
                        .floorToDouble();
                // Wrap lets each card take the height of its content, unlike
                // a grid cell, which clips it at a fixed aspect ratio.
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _metrics.map((m) => SizedBox(
                    width: tileWidth,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(m['icon'] as IconData, size: 24),
                            const SizedBox(height: 8),
                            Text(m['value'] as String,
                                style: Theme.of(context).textTheme.titleLarge),
                            Text(m['label'] as String,
                                style: Theme.of(context).textTheme.bodySmall),
                            Text(m['change'] as String,
                                style: TextStyle(
                                  color: (m['change'] as String).startsWith('+')
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_add)),
                title: const Text('New user registered'),
                subtitle: const Text('2 min ago'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.payment)),
                title: const Text('Order #1234 completed'),
                subtitle: const Text('15 min ago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
