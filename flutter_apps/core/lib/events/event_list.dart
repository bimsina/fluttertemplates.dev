import 'package:flutter/material.dart';

class _Event {
  final String title;
  final String date;
  final String place;
  final String price;
  final IconData icon;
  final Color color;
  const _Event(
      this.title, this.date, this.place, this.price, this.icon, this.color);
}

class EventsList extends StatefulWidget {
  const EventsList({super.key});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  int _filter = 0;
  static const _filters = ['All', 'Music', 'Tech', 'Food', 'Sports'];

  static const _events = [
    _Event('Indie Nights Live', 'Fri, Jul 12 · 8 PM', 'The Warehouse', '\$25',
        Icons.music_note, Color(0xFFBA68C8)),
    _Event('Flutter DevFest', 'Sat, Jul 13 · 10 AM', 'Tech Hub', 'Free',
        Icons.code, Color(0xFF42A5F5)),
    _Event('Street Food Fair', 'Sun, Jul 14 · 12 PM', 'Riverside Park', '\$10',
        Icons.fastfood, Color(0xFFFFB74D)),
    _Event('City Marathon', 'Sun, Jul 21 · 6 AM', 'Downtown', '\$40',
        Icons.directions_run, Color(0xFF66BB6A)),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Center(
                child: ChoiceChip(
                  label: Text(_filters[i]),
                  selected: _filter == i,
                  onSelected: (_) => setState(() => _filter = i),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, i) {
                final e = _events[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        color: e.color.withValues(alpha: 0.2),
                        child: Center(
                            child:
                                Icon(e.icon, size: 56, color: e.color)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14,
                                    color: scheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(e.date,
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14,
                                    color: scheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(e.place,
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant)),
                                const Spacer(),
                                Text(e.price,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
