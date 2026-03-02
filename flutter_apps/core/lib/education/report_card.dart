import 'package:flutter/material.dart';

const _grades = [
  {'subject': 'Flutter Fundamentals', 'grade': 'A', 'score': 92},
  {'subject': 'Dart Programming', 'grade': 'A-', 'score': 88},
  {'subject': 'State Management', 'grade': 'B+', 'score': 87},
  {'subject': 'Firebase', 'grade': 'A', 'score': 94},
];

class ReportCard extends StatelessWidget {
  const ReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Card')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'GPA: 3.8',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('Spring 2025', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._grades.map((g) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(g['subject'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        g['grade'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Text('${g['score']}%', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
