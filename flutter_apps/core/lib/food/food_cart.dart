import 'package:flutter/material.dart';

const _cartItems = [
  {'name': 'Margherita Pizza', 'price': 12.00, 'qty': 2},
  {'name': 'Garlic Bread', 'price': 5.00, 'qty': 1},
  {'name': 'Cola', 'price': 3.00, 'qty': 2},
];

class FoodCart extends StatelessWidget {
  const FoodCart({super.key});

  @override
  Widget build(BuildContext context) {
    var subtotal = 0.0;
    for (final item in _cartItems) {
      subtotal += (item['price'] as double) * (item['qty'] as int);
    }
    final delivery = 3.99;
    final total = subtotal + delivery;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (context, i) {
                final item = _cartItems[i];
                final lineTotal = (item['price'] as double) * (item['qty'] as int);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['name'] as String),
                    subtitle: Text('\$${item['price']} × ${item['qty']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${lineTotal.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () {},
                        ),
                        Text('${item['qty']}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () {},
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
                  onPressed: () {},
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
