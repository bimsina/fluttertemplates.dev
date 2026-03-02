import 'package:flutter/material.dart';

const _plans = [
  {
    'name': 'Free',
    'price': '\$0',
    'period': '/mo',
    'features': ['3 projects', '1GB storage'],
  },
  {
    'name': 'Pro',
    'price': '\$19',
    'period': '/mo',
    'features': ['Unlimited projects', '10GB storage', 'Priority support'],
    'popular': true,
  },
  {
    'name': 'Enterprise',
    'price': '\$99',
    'period': '/mo',
    'features': [
      'Everything in Pro',
      'Custom integrations',
      'Dedicated support',
    ],
  },
];

class PricingCards extends StatelessWidget {
  const PricingCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _plans.asMap().entries.map((e) {
          final p = e.value;
          final popular = p['popular'] as bool? ?? false;
          return Card(
            margin: EdgeInsets.only(bottom: 12, top: popular ? 0 : 0),
            elevation: popular ? 4 : 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (popular)
                    Chip(
                      label: const Text('Most Popular'),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  if (popular) const SizedBox(height: 12),
                  Text(
                    p['name'] as String,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        p['price'] as String,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(p['period'] as String),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(p['features'] as List<String>).map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 18, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(f),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Get Started'),
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
