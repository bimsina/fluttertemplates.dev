import 'package:flutter/material.dart';

const _products = [
  {'title': 'Product A', 'price': '\$29.99'},
  {'title': 'Product B', 'price': '\$49.99'},
  {'title': 'Product C', 'price': '\$19.99'},
];

class ProductList extends StatefulWidget {
  /// Called with the product's title. Without it the demo shows a SnackBar
  /// and counts adds itself.
  final ValueChanged<String>? onAddToCart;

  /// The host's cart size for the badge. With [onAddToCart] but no count the
  /// badge stays hidden, since only the host knows what the cart holds.
  final int? cartCount;

  const ProductList({super.key, this.onAddToCart, this.cartCount});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  var _inCart = 0;

  void _add(String title) {
    final callback = widget.onAddToCart;
    if (callback != null) {
      callback(title);
    } else {
      setState(() => _inCart++);
      _showDemo(context, '$title added to cart (demo)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final count =
        widget.cartCount ?? (widget.onAddToCart == null ? _inCart : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Semantics(
              label: count == null ? 'Cart' : '$count in cart',
              child: Badge.count(
                count: count ?? 0,
                isLabelVisible: (count ?? 0) > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
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
                  color: Colors.primaries[i % Colors.primaries.length]
                      .withValues(alpha: 0.3),
                ),
              ),
              title: Text(p['title'] as String),
              subtitle: Text(p['price'] as String),
              trailing: FilledButton(
                onPressed: () => _add(p['title'] as String),
                child: const Text('Add to Cart'),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
