import 'package:flutter/material.dart';

const _products = [
  {'title': 'Product A', 'price': '\$29.99'},
  {'title': 'Product B', 'price': '\$49.99'},
  {'title': 'Product C', 'price': '\$19.99'},
];

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, i) {
          final p = _products[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: SizedBox(
                width: 60,
                height: 60,
                child: Container(
                  color: Colors.primaries[i].withValues(alpha: 0.3),
                ),
              ),
              title: Text(p['title'] as String),
              subtitle: Text(p['price'] as String),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Add to Cart'),
              ),
            ),
          );
        },
      ),
    );
  }
}
