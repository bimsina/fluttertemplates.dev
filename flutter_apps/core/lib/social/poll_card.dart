import 'package:flutter/material.dart';

class PollCard extends StatefulWidget {
  const PollCard({super.key});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  int? _selected;
  final _votes = [12, 8, 5];
  final _options = ['Option A', 'Option B', 'Option C'];

  int get _total => _votes.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poll')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What\'s your favorite?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...List.generate(3, (i) {
                final pct = _total > 0 ? _votes[i] / _total : 0.0;
                final voted = _selected != null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_options[i]),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: _selected == null
                            ? () => setState(() => _selected = i)
                            : null,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                if (voted)
                                  Container(
                                    width: constraints.maxWidth * pct,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (voted)
                        Text('${(_votes[i] / _total * 100).round()}%'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
