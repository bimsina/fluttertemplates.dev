import 'package:flutter/material.dart';

const _steps = [
  {'title': 'Order placed', 'done': true, 'time': '2:30 PM'},
  {'title': 'Preparing', 'done': true, 'time': '2:45 PM'},
  {'title': 'Out for delivery', 'done': true, 'time': '3:15 PM'},
  {'title': 'Delivered', 'done': false, 'time': null},
];

class DeliveryTracking extends StatelessWidget {
  const DeliveryTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Tracking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.two_wheeler, size: 32, color: Colors.orange.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #1234', style: Theme.of(context).textTheme.titleMedium),
                          Text('Pizza Palace → Your address',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(_steps.length, (i) {
              final s = _steps[i];
              final isLast = i == _steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s['done'] as bool
                                ? Colors.green
                                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          child: (s['done'] as bool)
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: (s['done'] as bool)
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['title'] as String),
                            if (s['time'] != null)
                              Text(s['time'] as String,
                                  style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
