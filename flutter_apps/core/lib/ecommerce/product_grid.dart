import 'package:flutter/material.dart';

const _products = [
  {'title': 'Product 1', 'price': '\$29.99', 'rating': 4.5},
  {'title': 'Product 2', 'price': '\$49.99', 'rating': 4.8},
  {'title': 'Product 3', 'price': '\$19.99', 'rating': 4.2},
  {'title': 'Product 4', 'price': '\$89.99', 'rating': 4.9},
  {'title': 'Product 5', 'price': '\$34.99', 'rating': 4.0},
  {'title': 'Product 6', 'price': '\$59.99', 'rating': 4.6},
];

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, i) {
          final p = _products[i];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.primaries[i % Colors.primaries.length]
                        .withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p['price'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber[700]),
                              Text(
                                '${p['rating']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
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
}
