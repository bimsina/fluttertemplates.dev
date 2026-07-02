import 'package:flutter/material.dart';

class _Deal {
  final String company;
  final String value;
  final String owner;
  const _Deal(this.company, this.value, this.owner);
}

class _Stage {
  final String name;
  final Color color;
  final List<_Deal> deals;
  const _Stage(this.name, this.color, this.deals);
}

class DealPipeline extends StatelessWidget {
  const DealPipeline({super.key});

  static const _stages = [
    _Stage('Lead', Color(0xFF90A4AE), [
      _Deal('Northwind Ltd', '\$4.2k', 'AK'),
      _Deal('Sunrise Media', '\$1.8k', 'BR'),
    ]),
    _Stage('Qualified', Color(0xFF42A5F5), [
      _Deal('Acme Corp', '\$12k', 'CD'),
      _Deal('Bluewave', '\$8.5k', 'AK'),
      _Deal('Cedar & Co', '\$3k', 'EP'),
    ]),
    _Stage('Proposal', Color(0xFFFFB74D), [
      _Deal('Vertex Labs', '\$22k', 'BR'),
    ]),
    _Stage('Won', Color(0xFF66BB6A), [
      _Deal('Orbit Studio', '\$15k', 'CD'),
      _Deal('Pinecone Inc', '\$6.7k', 'AK'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pipeline')),
      body: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        children: [
          for (final stage in _stages)
            Container(
              width: 240,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: stage.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(stage.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${stage.deals.length}',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final d in stage.deals)
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(d.company,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(d.value,
                                          style: TextStyle(
                                              color: scheme.primary,
                                              fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      CircleAvatar(
                                          radius: 12,
                                          child: Text(d.owner,
                                              style: const TextStyle(
                                                  fontSize: 10))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
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
