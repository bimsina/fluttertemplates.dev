import 'package:flutter/material.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  static const _titles = ['Overview', 'Users', 'Orders', 'Settings'];
  static const _pages = [
    _OverviewPage(),
    _ListPage(
      icon: Icons.person_outline,
      items: [
        ('Alex Kim', 'Admin'),
        ('Bianca Rossi', 'Editor'),
        ('Chen Wei', 'Viewer'),
      ],
    ),
    _ListPage(
      icon: Icons.receipt_long_outlined,
      items: [
        ('Order #1204', 'Paid · \$240.00'),
        ('Order #1203', 'Shipped · \$89.50'),
        ('Order #1202', 'Refunded · \$32.00'),
      ],
    ),
    _ListPage(
      icon: Icons.tune,
      items: [
        ('Workspace', 'Name, logo and timezone'),
        ('Notifications', 'Email and push alerts'),
        ('Billing', 'Plan and payment method'),
      ],
    ),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.dashboard_customize, color: scheme.primary),
            ),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.insights_outlined), label: Text('Overview')),
              NavigationRailDestination(
                  icon: Icon(Icons.people_outline), label: Text('Users')),
              NavigationRailDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: Text('Orders')),
              NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined), label: Text('Settings')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(_titles[_index],
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                          tooltip: 'Notifications',
                          onPressed: () => _showDemo(context, 'Notifications (demo)'),
                          icon: const Icon(Icons.notifications_outlined)),
                      const SizedBox(width: 8),
                      const CircleAvatar(child: Text('AK')),
                    ],
                  ),
                ),
                Expanded(child: _pages[_index]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _MetricCard(
                label: 'Revenue',
                value: '\$48.2k',
                delta: '+12%',
                icon: Icons.payments_outlined,
                up: true),
            _MetricCard(
                label: 'Users',
                value: '8,942',
                delta: '+3.1%',
                icon: Icons.person_add_outlined,
                up: true),
            _MetricCard(
                label: 'Orders',
                value: '1,204',
                delta: '-2%',
                icon: Icons.receipt_long_outlined,
                up: false),
            _MetricCard(
                label: 'Churn',
                value: '1.8%',
                delta: '-0.4%',
                icon: Icons.trending_down,
                up: true),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly revenue',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      for (final v in const [
                        0.5,
                        0.7,
                        0.4,
                        0.9,
                        0.65,
                        0.8,
                        1.0
                      ])
                        Container(
                          width: 28,
                          height: 150 * v,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ListPage extends StatelessWidget {
  final IconData icon;
  final List<(String, String)> items;
  const _ListPage({required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (title, subtitle) in items)
          Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
            ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final bool up;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.up,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const Spacer(),
              Text(delta,
                  style: TextStyle(
                      color: up ? Colors.green : scheme.error,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
