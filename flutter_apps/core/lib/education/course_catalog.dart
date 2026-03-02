import 'package:flutter/material.dart';

const _courses = [
  {'title': 'Flutter Fundamentals', 'instructor': 'Jane Doe', 'rating': 4.8, 'hours': 12},
  {'title': 'Dart Deep Dive', 'instructor': 'John Smith', 'rating': 4.6, 'hours': 8},
  {'title': 'State Management', 'instructor': 'Sarah Lee', 'rating': 4.9, 'hours': 6},
  {'title': 'Firebase Integration', 'instructor': 'Mike Brown', 'rating': 4.5, 'hours': 10},
];

class CourseCatalog extends StatelessWidget {
  const CourseCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Catalog')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _courses.length,
        itemBuilder: (context, i) {
          final c = _courses[i];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.primaries[i].withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        c['instructor'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          Text(' ${c['rating']}'),
                          const Spacer(),
                          Text('${c['hours']} hrs'),
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
    );
  }
}
