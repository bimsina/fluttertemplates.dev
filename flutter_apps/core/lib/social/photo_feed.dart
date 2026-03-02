import 'package:flutter/material.dart';

const _posts = [
  {'user': 'Alice', 'caption': 'Beautiful sunset today!'},
  {'user': 'Bob', 'caption': 'Check out my new project'},
];

class PhotoFeed extends StatelessWidget {
  const PhotoFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, i) {
          final p = _posts[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: Text((p['user'] as String)[0]),
                  ),
                  title: Text(p['user'] as String),
                ),
                Container(
                  height: 250,
                  color: Colors.primaries[i].withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(p['caption'] as String),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
