import 'package:flutter/material.dart';

const _destinations = [
  {'name': 'Paris', 'country': 'France', 'price': '\$899', 'rating': 4.8},
  {'name': 'Tokyo', 'country': 'Japan', 'price': '\$1,299', 'rating': 4.9},
  {'name': 'Santorini', 'country': 'Greece', 'price': '\$749', 'rating': 4.7},
  {'name': 'Bali', 'country': 'Indonesia', 'price': '\$599', 'rating': 4.6},
];

class DestinationCards extends StatelessWidget {
  const DestinationCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destinations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _destinations.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.primaries[i % Colors.primaries.length]
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['name'] as String,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              d['country'] as String,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              d['price'] as String,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                const SizedBox(width: 4),
                                Text('${d['rating']}'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
