import 'package:flutter/material.dart';

const _days = [
  {'date': 'Day 1', 'title': 'Arrival', 'desc': 'Check-in, explore local area'},
  {'date': 'Day 2', 'title': 'City Tour', 'desc': 'Museums and landmarks'},
  {'date': 'Day 3', 'title': 'Beach Day', 'desc': 'Relax at the coast'},
  {'date': 'Day 4', 'title': 'Departure', 'desc': 'Check-out and transfer'},
];

class TripItinerary extends StatelessWidget {
  const TripItinerary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Itinerary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                child: const Icon(Icons.flight),
              ),
              title: const Text('Paris Adventure'),
              subtitle: const Text('Mar 15 - Mar 19, 2025'),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_days.length, (i) {
            final d = _days[i];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.circle, size: 12, color: Colors.blue[700]),
                    ),
                    if (i < _days.length - 1)
                      Container(width: 2, height: 60, color: Colors.grey[300]),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['date'] as String,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            d['title'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(d['desc'] as String),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
