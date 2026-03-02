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
          final columns = List.generate(crossAxisCount, (_) => <double>[]);

          for (var i = 0; i < _items.length; i++) {
            final h = (_items[i]['h'] as double) + 48;
            final col = i % crossAxisCount;
            final top = columns[col].isEmpty ? 0.0 : columns[col].last + spacing;
            columns[col].add(top + h);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(crossAxisCount, (col) {
                return SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      for (var i = col; i < _items.length; i += crossAxisCount)
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
      height: height + 48,
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
