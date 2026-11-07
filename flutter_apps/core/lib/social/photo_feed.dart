import 'package:flutter/material.dart';

const _posts = [
  {'user': 'Alice', 'caption': 'Beautiful sunset today!'},
  {'user': 'Bob', 'caption': 'Check out my new project'},
];

class PhotoFeed extends StatefulWidget {
  const PhotoFeed({super.key});

  @override
  State<PhotoFeed> createState() => _PhotoFeedState();
}

class _PhotoFeedState extends State<PhotoFeed> {
  final _favorites = <int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, i) {
          final p = _posts[i];
          final favorite = _favorites.contains(i);
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
                  color: Colors.primaries[i % Colors.primaries.length].withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(p['caption'] as String),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: favorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      isSelected: favorite,
                      icon: const Icon(Icons.favorite_border),
                      selectedIcon: const Icon(Icons.favorite),
                      onPressed: () => setState(() {
                        if (!_favorites.add(i)) _favorites.remove(i);
                      }),
                    ),
                    IconButton(
                      tooltip: 'Comment',
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () => _showDemo(context, 'Comment (demo)'),
                    ),
                    IconButton(
                      tooltip: 'Share',
                      icon: const Icon(Icons.share),
                      onPressed: () => _showDemo(context, 'Share (demo)'),
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

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
