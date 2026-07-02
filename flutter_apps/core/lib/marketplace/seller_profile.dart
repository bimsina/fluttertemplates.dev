import 'package:flutter/material.dart';

class SellerProfile extends StatelessWidget {
  const SellerProfile({super.key});

  static const _items = [
    (Icons.chair, '\$120', Color(0xFF8D6E63)),
    (Icons.headphones, '\$90', Color(0xFFBA68C8)),
    (Icons.pedal_bike, '\$340', Color(0xFF42A5F5)),
    (Icons.light, '\$28', Color(0xFFFFB74D)),
    (Icons.table_bar, '\$60', Color(0xFF26A69A)),
    (Icons.shelves, '\$75', Color(0xFF66BB6A)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Seller')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(radius: 34, child: Text('EP')),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Elena Petrova',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          const Text('4.9'),
                          Text('  ·  Joined 2023',
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                FilledButton(onPressed: () {}, child: const Text('Follow')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _stat(scheme, '48', 'Sales')),
                Expanded(child: _stat(scheme, '312', 'Followers')),
                Expanded(child: _stat(scheme, '12', 'Listings')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text('Listings',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (final (icon, price, color) in _items)
                Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Icon(icon, color: color, size: 36)),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(price,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _stat(ColorScheme scheme, String value, String label) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
