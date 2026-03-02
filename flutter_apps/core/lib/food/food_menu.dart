import 'package:flutter/material.dart';

const _sections = [
  {'name': 'Pizzas', 'items': [
    {'name': 'Margherita', 'price': '\$12', 'desc': 'Tomato, mozzarella, basil'},
    {'name': 'Pepperoni', 'price': '\$14', 'desc': 'Pepperoni, mozzarella'},
    {'name': 'Hawaiian', 'price': '\$13', 'desc': 'Ham, pineapple, mozzarella'},
  ]},
  {'name': 'Sides', 'items': [
    {'name': 'Garlic Bread', 'price': '\$5', 'desc': 'With herb butter'},
    {'name': 'Caesar Salad', 'price': '\$8', 'desc': 'Romaine, parmesan, croutons'},
  ]},
  {'name': 'Drinks', 'items': [
    {'name': 'Cola', 'price': '\$3', 'desc': '330ml'},
    {'name': 'Lemonade', 'price': '\$4', 'desc': 'Fresh squeezed'},
  ]},
];

class FoodMenu extends StatelessWidget {
  const FoodMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
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
              ...(section['items'] as List).map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item['name'] as String),
                      subtitle: Text(item['desc'] as String),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item['price'] as String,
                              style: Theme.of(context).textTheme.titleMedium),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
