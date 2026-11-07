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

  void _vote(int option) {
    setState(() {
      _selected = option;
      _votes[option]++;
    });
  }

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
              ...List.generate(_options.length, (i) {
                final pct = _total > 0 ? _votes[i] / _total : 0.0;
                final voted = _selected != null;
                final isChoice = _selected == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_options[i]),
                          if (isChoice) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: voted ? null : () => _vote(i),
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
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  width: voted ? constraints.maxWidth * pct : 0,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(
                                      alpha: isChoice ? 0.7 : 0.35,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (voted) Text('${(pct * 100).round()}%'),
                    ],
                  ),
                );
              }),
              if (_selected != null) Text('$_total votes'),
            ],
          ),
        ),
      ),
    );
  }
}
