import 'package:flutter/material.dart';

const _ratings = [5, 4, 3, 2, 1];
const _counts = [12, 8, 3, 1, 0];
final _maxCount = _counts.reduce((a, b) => a > b ? a : b);
final _totalReviews = _counts.reduce((a, b) => a + b);
final _averageRating = _totalReviews == 0
    ? 0.0
    : List.generate(
          _ratings.length,
          (i) => _ratings[i] * _counts[i],
        ).reduce((a, b) => a + b) /
        _totalReviews;
const _reviews = [
  {'user': 'Alice', 'rating': 5, 'text': 'Great product!'},
  {'user': 'Bob', 'rating': 4, 'text': 'Good value for money.'},
];

class ProductReviews extends StatelessWidget {
  const ProductReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: _ratings.asMap().entries.map((e) {
                    final pct = _maxCount > 0
                        ? (_counts[e.key] / _maxCount)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('${e.value}'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                            ),
                          ),
                          Text(' ${_counts[e.key]}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          ..._reviews.map(
            (r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text((r['user'] as String)[0])),
                        const SizedBox(width: 8),
                        Text(r['user'] as String),
                        const Spacer(),
                        ...List.generate(
                          r['rating'] as int,
                          (_) => Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r['text'] as String),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
