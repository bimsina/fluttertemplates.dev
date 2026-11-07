import 'package:flutter/material.dart';

/// One line of the cart, used for [FoodCart.items] and [FoodCart.onCheckout].
class FoodCartItem {
  final String name;
  final double price;
  final int quantity;

  const FoodCartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

const _sampleItems = [
  FoodCartItem(name: 'Margherita Pizza', price: 12.00, quantity: 2),
  FoodCartItem(name: 'Garlic Bread', price: 5.00, quantity: 1),
  FoodCartItem(name: 'Cola', price: 3.00, quantity: 2),
];

const _delivery = 3.99;

class FoodCart extends StatefulWidget {
  /// The starting lines. Without it the cart opens with sample items. A new
  /// list replaces the cart, including any quantities changed here.
  final List<FoodCartItem>? items;

  /// Called with the current lines and the total including delivery. Without
  /// it the demo shows a SnackBar. Checkout is disabled while the cart is empty.
  final void Function(List<FoodCartItem> items, double total)? onCheckout;

  const FoodCart({super.key, this.items, this.onCheckout});

  @override
  State<FoodCart> createState() => _FoodCartState();
}

class _FoodCartState extends State<FoodCart> {
  late List<FoodCartItem> _items = _startingItems();

  List<FoodCartItem> _startingItems() => [
    for (final item in widget.items ?? _sampleItems)
      if (item.quantity > 0) item,
  ];

  @override
  void didUpdateWidget(FoodCart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) _items = _startingItems();
  }

  // Reaching zero removes the line.
  void _setQuantity(int index, int quantity) {
    setState(() {
      if (quantity < 1) {
        _items.removeAt(index);
      } else {
        final item = _items[index];
        _items[index] = FoodCartItem(
          name: item.name,
          price: item.price,
          quantity: quantity,
        );
      }
    });
  }

  void _checkout(double total) {
    final onCheckout = widget.onCheckout;
    if (onCheckout != null) {
      onCheckout(List.unmodifiable(_items), total);
    } else {
      _showDemo(context, 'Checkout (demo)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final delivery = _items.isEmpty ? 0.0 : _delivery;
    final total = subtotal + delivery;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      final lineTotal = item.price * item.quantity;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '\$${item.price.toStringAsFixed(2)} × '
                            '${item.quantity} = '
                            '\$${lineTotal.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: item.quantity == 1
                                    ? 'Remove ${item.name}'
                                    : 'Decrease quantity',
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _setQuantity(i, item.quantity - 1),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                tooltip: 'Increase quantity',
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _setQuantity(i, item.quantity + 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              children: [
                _SummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                _SummaryRow('Delivery', '\$${delivery.toStringAsFixed(2)}'),
                const Divider(),
                _SummaryRow('Total', '\$${total.toStringAsFixed(2)}',
                    bold: true),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _items.isEmpty ? null : () => _checkout(total),
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? Theme.of(context).textTheme.titleMedium : null),
          Text(value, style: bold ? Theme.of(context).textTheme.titleMedium : null),
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
