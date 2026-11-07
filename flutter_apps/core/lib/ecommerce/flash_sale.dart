import 'dart:async';

import 'package:flutter/material.dart';

const _products = [
  {'title': 'Deal 1', 'price': '\$19', 'original': '\$39'},
  {'title': 'Deal 2', 'price': '\$29', 'original': '\$59'},
  {'title': 'Deal 3', 'price': '\$14', 'original': '\$28'},
];

class FlashSale extends StatefulWidget {
  const FlashSale({super.key});

  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
  final _endsAt = DateTime.now().add(const Duration(hours: 2, minutes: 30));
  late Duration _remaining = _timeLeft();
  Timer? _timer;

  // Rounded up, so the clock starts on 2h 30m 0s and reaches zero when it ends.
  Duration _timeLeft() {
    final left = _endsAt.difference(DateTime.now());
    if (left <= Duration.zero) return Duration.zero;
    return Duration(seconds: (left.inMilliseconds / 1000).ceil());
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _remaining = _timeLeft());
      if (_remaining == Duration.zero) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 116px of image and padding plus two lines of text, which grow with scale.
    final cardHeight = 116 + MediaQuery.textScalerOf(context).scale(64);

    return Scaffold(
      appBar: AppBar(title: const Text('Flash Sale')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _remaining == Duration.zero
                        ? 'Sale ended'
                        : '${_remaining.inHours}h ${_remaining.inMinutes % 60}m '
                              '${_remaining.inSeconds % 60}s left',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _products.length,
              itemBuilder: (context, i) {
                final p = _products[i];
                return Card(
                  margin: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.primaries[i % Colors.primaries.length]
                                .withValues(alpha: 0.3),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-50%',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['title'] as String),
                              Wrap(
                                spacing: 4,
                                children: [
                                  Text(
                                    p['price'] as String,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    p['original'] as String,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
