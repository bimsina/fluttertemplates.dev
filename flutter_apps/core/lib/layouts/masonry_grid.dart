import 'package:flutter/material.dart';

const _items = [
  {'title': 'Design', 'h': 120.0, 'color': Colors.blue},
  {'title': 'Nature', 'h': 180.0, 'color': Colors.green},
  {'title': 'Travel', 'h': 100.0, 'color': Colors.orange},
  {'title': 'Tech', 'h': 220.0, 'color': Colors.purple},
  {'title': 'Food', 'h': 140.0, 'color': Colors.red},
  {'title': 'Art', 'h': 160.0, 'color': Colors.teal},
  {'title': 'Music', 'h': 90.0, 'color': Colors.indigo},
  {'title': 'Sports', 'h': 200.0, 'color': Colors.amber},
  {'title': 'Science', 'h': 130.0, 'color': Colors.cyan},
];

class MasonryGrid extends StatelessWidget {
  const MasonryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masonry Grid')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const crossAxisCount = 2;
          const spacing = 8.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (crossAxisCount + 1)) /
                  crossAxisCount;

          // Send each item to whichever column is currently shortest.
          final columns = List.generate(crossAxisCount, (_) => <int>[]);
          final heights = List.filled(crossAxisCount, 0.0);
          for (var i = 0; i < _items.length; i++) {
            var shortest = 0;
            for (var col = 1; col < crossAxisCount; col++) {
              if (heights[col] < heights[shortest]) shortest = col;
            }
            columns[shortest].add(i);
            heights[shortest] += (_items[i]['h'] as double) + spacing;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(spacing),
            child: Row(
              spacing: spacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(crossAxisCount, (col) {
                return SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      for (final i in columns[col])
                        Padding(
                          padding: const EdgeInsets.only(bottom: spacing),
                          child: _MasonryCard(
                            title: _items[i]['title'] as String,
                            height: _items[i]['h'] as double,
                            color: _items[i]['color'] as Color,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _MasonryCard extends StatelessWidget {
  final String title;
  final double height;
  final Color color;

  const _MasonryCard(
      {required this.title, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
