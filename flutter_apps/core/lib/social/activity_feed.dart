import 'package:flutter/material.dart';

const _activities = [
  {'icon': Icons.favorite, 'text': 'Liked your post'},
  {'icon': Icons.comment, 'text': 'Commented on your photo'},
  {'icon': Icons.person_add, 'text': 'Started following you'},
];

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ListView.builder(
        itemCount: _activities.length,
        itemBuilder: (context, i) {
          final a = _activities[i];
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(width: 24),
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.primaries[i].withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a['icon'] as IconData, size: 20),
                    ),
                    if (i < _activities.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(a['text'] as String),
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
