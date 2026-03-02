import 'package:flutter/material.dart';

const _events = [
  {'title': 'Team Meeting', 'time': '10:00 AM', 'location': 'Room A'},
  {'title': 'Lunch', 'time': '12:30 PM', 'location': 'Cafeteria'},
  {'title': 'Design Review', 'time': '2:00 PM', 'location': 'Room B'},
  {'title': 'Standup', 'time': '4:00 PM', 'location': 'Remote'},
];

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, i) {
          final e = _events[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event, color: Colors.blue[700]),
              ),
              title: Text(e['title'] as String),
              subtitle: Text('${e['time']} • ${e['location']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
