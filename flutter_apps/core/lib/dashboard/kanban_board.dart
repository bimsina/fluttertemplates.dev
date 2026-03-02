import 'package:flutter/material.dart';

const _columns = [
  {'title': 'To Do', 'color': Colors.grey, 'tasks': ['Task 1', 'Task 2', 'Task 3']},
  {'title': 'In Progress', 'color': Colors.blue, 'tasks': ['Task 4', 'Task 5']},
  {'title': 'Review', 'color': Colors.orange, 'tasks': ['Task 6']},
  {'title': 'Done', 'color': Colors.green, 'tasks': ['Task 7', 'Task 8']},
];

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Board')),
      body: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        children: _columns.map((col) => SizedBox(
          width: 220,
          child: Card(
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (col['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Text(col['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('${(col['tasks'] as List).length}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: (col['tasks'] as List).length,
                    itemBuilder: (context, i) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text((col['tasks'] as List)[i]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
