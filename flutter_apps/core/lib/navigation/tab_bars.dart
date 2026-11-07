import 'package:flutter/material.dart';

class TabBars extends StatefulWidget {
  const TabBars({super.key});

  @override
  State<TabBars> createState() => _TabBarsState();
}

class _TabBarsState extends State<TabBars> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tab Bar'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo_outlined), text: 'Photos'),
              Tab(icon: Icon(Icons.video_library_outlined), text: 'Videos'),
              Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Day')),
                  ButtonSegment(value: 1, label: Text('Week')),
                  ButtonSegment(value: 2, label: Text('Month')),
                ],
                selected: {_segment},
                onSelectionChanged: (s) => setState(() => _segment = s.first),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _GridTab(icon: Icons.photo, count: 12, period: _segment),
                  _GridTab(
                    icon: Icons.play_circle_outline,
                    count: 6,
                    period: _segment,
                  ),
                  _GridTab(icon: Icons.music_note, count: 9, period: _segment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridTab extends StatelessWidget {
  final IconData icon;
  final int count;
  final int period; // 0 day, 1 week, 2 month
  const _GridTab({
    required this.icon,
    required this.count,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(12),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: List.generate(
        // Day shows a third of the items, Week two thirds, Month all of them.
        count * (period + 1) ~/ 3,
        (i) => Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
