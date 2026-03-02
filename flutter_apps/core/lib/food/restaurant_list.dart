import 'package:flutter/material.dart';

const _restaurants = [
  {'name': 'Pizza Palace', 'cuisine': 'Italian', 'rating': 4.5, 'delivery': '25-35 min'},
  {'name': 'Sushi Bar', 'cuisine': 'Japanese', 'rating': 4.8, 'delivery': '30-45 min'},
  {'name': 'Taco Fiesta', 'cuisine': 'Mexican', 'rating': 4.2, 'delivery': '20-30 min'},
  {'name': 'Burger King', 'cuisine': 'American', 'rating': 4.0, 'delivery': '15-25 min'},
  {'name': 'Thai Garden', 'cuisine': 'Thai', 'rating': 4.6, 'delivery': '35-45 min'},
];

class RestaurantList extends StatelessWidget {
  const RestaurantList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _restaurants.length,
        itemBuilder: (context, i) {
          final r = _restaurants[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.primaries[i % Colors.primaries.length]
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['name'] as String,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(r['cuisine'] as String,
                            style: Theme.of(context).textTheme.bodySmall),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[700]),
                            Text(' ${r['rating']}', style: Theme.of(context).textTheme.bodySmall),
                            Text(' • ${r['delivery']}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
