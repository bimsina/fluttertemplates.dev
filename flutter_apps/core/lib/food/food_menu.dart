import 'package:flutter/material.dart';

const _sections = [
  {'name': 'Pizzas', 'items': [
    {'name': 'Margherita', 'price': 12, 'desc': 'Tomato, mozzarella, basil'},
    {'name': 'Pepperoni', 'price': 14, 'desc': 'Pepperoni, mozzarella'},
    {'name': 'Hawaiian', 'price': 13, 'desc': 'Ham, pineapple, mozzarella'},
  ]},
  {'name': 'Sides', 'items': [
    {'name': 'Garlic Bread', 'price': 5, 'desc': 'With herb butter'},
    {'name': 'Caesar Salad', 'price': 8, 'desc': 'Romaine, parmesan, croutons'},
  ]},
  {'name': 'Drinks', 'items': [
    {'name': 'Cola', 'price': 3, 'desc': '330ml'},
    {'name': 'Lemonade', 'price': 4, 'desc': 'Fresh squeezed'},
  ]},
];

class FoodMenu extends StatefulWidget {
  const FoodMenu({super.key});

  @override
  State<FoodMenu> createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  // Quantity per dish name. Dishes at zero have no entry.
  final _order = <String, int>{};

  void _change(String name, int delta) {
    setState(() {
      final quantity = (_order[name] ?? 0) + delta;
      if (quantity > 0) {
        _order[name] = quantity;
      } else {
        _order.remove(name);
      }
    });
  }

  int get _total {
    var total = 0;
    for (final section in _sections) {
      for (final item in section['items'] as List) {
        total += (item['price'] as int) * (_order[item['name']] ?? 0);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final count = _order.values.fold<int>(0, (sum, q) => sum + q);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      bottomNavigationBar: count == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '$count ${count == 1 ? 'item' : 'items'} · \$$_total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        itemBuilder: (context, si) {
          final section = _sections[si];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(section['name'] as String,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              ...(section['items'] as List).map((item) {
                final name = item['name'] as String;
                final quantity = _order[name] ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('\$${item['price']} · ${item['desc']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (quantity > 0) ...[
                          IconButton(
                            tooltip: 'Remove one $name',
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _change(name, -1),
                          ),
                          Text('$quantity'),
                        ],
                        IconButton(
                          tooltip: 'Add $name to order',
                          icon: const Icon(Icons.add_circle),
                          onPressed: () => _change(name, 1),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
