import 'package:flutter/material.dart';

const _categories = [
  {'name': 'Electronics', 'icon': Icons.devices},
  {'name': 'Fashion', 'icon': Icons.checkroom},
  {'name': 'Home', 'icon': Icons.home},
  {'name': 'Sports', 'icon': Icons.sports_soccer},
  {'name': 'Books', 'icon': Icons.menu_book},
  {'name': 'Toys', 'icon': Icons.toys},
];

class CategoryBrowser extends StatelessWidget {
  const CategoryBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final c = _categories[i];
          return Card(
            child: InkWell(
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(c['icon'] as IconData, size: 48),
                  const SizedBox(height: 8),
                  Text(c['name'] as String),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
