import 'package:flutter/material.dart';

const _assignments = [
  {'title': 'Widget Exercise', 'due': 'Mar 5', 'status': 'Pending'},
  {'title': 'State Lab', 'due': 'Mar 3', 'status': 'Submitted'},
  {'title': 'Final Project', 'due': 'Mar 15', 'status': 'Pending'},
];

class AssignmentList extends StatelessWidget {
  const AssignmentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assignments.length,
        itemBuilder: (context, i) {
          final a = _assignments[i];
          final isSubmitted = (a['status'] as String) == 'Submitted';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isSubmitted
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                child: Icon(
                  isSubmitted ? Icons.check : Icons.assignment,
                  color: isSubmitted ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(a['title'] as String),
              subtitle: Text('Due ${a['due']}'),
              trailing: Chip(
                label: Text(a['status'] as String, style: const TextStyle(fontSize: 12)),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
