import 'package:flutter/material.dart';

const _reviews = [
  {'user': 'Alice', 'rating': 5, 'date': '2 days ago', 'text': 'Amazing pizza! Best in town.'},
  {'user': 'Bob', 'rating': 4, 'date': '1 week ago', 'text': 'Good food, slow delivery.'},
  {'user': 'Carol', 'rating': 5, 'date': '2 weeks ago', 'text': 'Consistently great. My go-to spot.'},
];

class RestaurantReview extends StatelessWidget {
  const RestaurantReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('4.5', style: Theme.of(context).textTheme.headlineMedium),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < 4 ? Icons.star : Icons.star_half,
                        size: 16,
                        color: Colors.amber[700],
                      )),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('128', style: Theme.of(context).textTheme.titleMedium),
                    Text('Reviews', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Write Review'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              itemBuilder: (context, i) {
                final r = _reviews[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(child: Text((r['user'] as String)[0])),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['user'] as String),
                                  Row(
                                    children: [
                                      ...List.generate(
                                          r['rating'] as int,
                                          (_) => Icon(Icons.star, size: 12, color: Colors.amber[700])),
                                      Text(' • ${r['date']}',
                                          style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r['text'] as String),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
