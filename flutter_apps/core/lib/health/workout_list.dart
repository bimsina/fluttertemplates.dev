import 'package:flutter/material.dart';

const _workouts = [
  {'name': 'Morning Run', 'duration': 30, 'calories': 280, 'date': 'Today'},
  {'name': 'Full Body HIIT', 'duration': 45, 'calories': 420, 'date': 'Yesterday'},
  {'name': 'Yoga Flow', 'duration': 60, 'calories': 180, 'date': '2 days ago'},
  {'name': 'Strength Training', 'duration': 50, 'calories': 350, 'date': '3 days ago'},
];

class WorkoutList extends StatelessWidget {
  const WorkoutList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workouts.length,
        itemBuilder: (context, i) {
          final w = _workouts[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center, color: Colors.blue.shade700),
              ),
              title: Text(w['name'] as String),
              subtitle: Text('${w['duration']} min • ${w['calories']} cal • ${w['date']}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      ),
    );
  }
}
