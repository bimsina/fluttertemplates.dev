import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  /// Called with the title of an item after it leaves the wishlist.
  final ValueChanged<String>? onMoveToCart;

  const WishlistPage({super.key, this.onMoveToCart});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _items = [
    {'title': 'Product A', 'price': '\$29.99', 'hearted': true},
    {'title': 'Product B', 'price': '\$49.99', 'hearted': true},
  ];

  void _moveToCart(Map<String, Object> item) {
    final title = item['title'] as String;
    setState(() => _items.remove(item));
    widget.onMoveToCart?.call(title);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$title moved to cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: _items.isEmpty
          ? const Center(child: Text('Your wishlist is empty'))
          : GridView.builder(
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
                              color: Colors
                                  .primaries[i % Colors.primaries.length]
                                  .withValues(alpha: 0.3),
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
                                  onPressed: () => _moveToCart(item),
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
                          tooltip: item['hearted'] == true
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          icon: Icon(
                            item['hearted'] == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item['hearted'] == true ? Colors.red : null,
                          ),
                          onPressed: () => setState(
                            () => item['hearted'] = !(item['hearted'] as bool),
                          ),
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
