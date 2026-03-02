import 'package:flutter/material.dart';

const _posts = [
  {'title': '10 Hidden Gems in Tokyo', 'author': 'Sarah', 'date': 'Feb 28', 'likes': 234},
  {'title': 'Best Beaches in Bali', 'author': 'Mike', 'date': 'Feb 25', 'likes': 189},
  {'title': 'Santorini Sunset Guide', 'author': 'Emma', 'date': 'Feb 20', 'likes': 412},
];

class TravelBlog extends StatelessWidget {
  const TravelBlog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Blog'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, i) {
          final p = _posts[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.primaries[i].withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(radius: 10, backgroundColor: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text('${p['author']} • ${p['date']}',
                              style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          Icon(Icons.favorite_border, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${p['likes']}', style: Theme.of(context).textTheme.bodySmall),
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
