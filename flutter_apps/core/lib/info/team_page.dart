import 'package:flutter/material.dart';

const _team = [
  {'name': 'Jane Doe', 'role': 'CEO'},
  {'name': 'John Smith', 'role': 'CTO'},
  {'name': 'Sarah Lee', 'role': 'Design Lead'},
];

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Team')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _team.length,
        itemBuilder: (context, i) {
          final t = _team[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.primaries[i].withValues(alpha: 0.3),
                child: Text((t['name'] as String)[0]),
              ),
              title: Text(t['name'] as String),
              subtitle: Text(t['role'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
