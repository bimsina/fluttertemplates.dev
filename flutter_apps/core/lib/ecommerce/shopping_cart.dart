import 'package:flutter/material.dart';

const _items = [
  {'title': 'Item 1', 'price': 29.99, 'qty': 1},
  {'title': 'Item 2', 'price': 15.99, 'qty': 2},
];

/// One row of the order passed to [ShoppingCart.onCheckout].
class CartLine {
  final String title;
  final double price;
  final int quantity;

  const CartLine({
    required this.title,
    required this.price,
    required this.quantity,
  });
}

class ShoppingCart extends StatefulWidget {
  /// Called with the current lines and total. Without it the demo shows a
  /// SnackBar. Checkout is disabled while the cart is empty.
  final void Function(List<CartLine> lines, double total)? onCheckout;

  const ShoppingCart({super.key, this.onCheckout});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  // Each map is copied too: the ones in `_items` are const and can't be changed.
  final items = _items.map((e) => Map<String, dynamic>.from(e)).toList();

  double get _total =>
      items.fold(0, (sum, i) => sum + (i['price'] as num) * (i['qty'] as int));

  void _checkout() {
    final onCheckout = widget.onCheckout;
    if (onCheckout != null) {
      final lines = [
        for (final item in items)
          CartLine(
            title: item['title'] as String,
            price: (item['price'] as num).toDouble(),
            quantity: item['qty'] as int,
          ),
      ];
      onCheckout(lines, _total);
      return;
    }
    final count = items.fold<int>(0, (sum, i) => sum + (i['qty'] as int));
    final noun = count == 1 ? 'item' : 'items';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          'Checking out $count $noun for \$${_total.toStringAsFixed(2)} (demo)',
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return Dismissible(
                  key: Key(item['title'] as String),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => setState(() =>
                      items.removeWhere((x) => x['title'] == item['title'])),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(item['title'] as String),
                      subtitle: Text('\$${item['price']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Decrease quantity',
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (item['qty'] > 1) item['qty']--;
                              });
                            },
                          ),
                          Text('${item['qty']}'),
                          IconButton(
                            tooltip: 'Increase quantity',
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() => item['qty']++);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleLarge),
                    Text('\$${_total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: items.isEmpty ? null : _checkout,
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
