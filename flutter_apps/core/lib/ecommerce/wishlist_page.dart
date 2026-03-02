import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _items = [
    {'title': 'Product A', 'price': '\$29.99', 'hearted': true},
    {'title': 'Product B', 'price': '\$49.99', 'hearted': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          return Card(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.primaries[i].withValues(alpha: 0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String),
                          Text(item['price'] as String),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Move to Cart'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      item['hearted'] == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: item['hearted'] == true ? Colors.red : null,
                    ),
                    onPressed: () => setState(
                        () => item['hearted'] = !(item['hearted'] as bool)),
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
