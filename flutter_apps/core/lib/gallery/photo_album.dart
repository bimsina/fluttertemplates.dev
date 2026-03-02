import 'package:flutter/material.dart';

const _albums = [
  {'name': 'Vacation 2025', 'count': 24},
  {'name': 'Family', 'count': 56},
  {'name': 'Work', 'count': 12},
];

class PhotoAlbum extends StatelessWidget {
  const PhotoAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _albums.length,
        itemBuilder: (context, i) {
          final a = _albums[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.primaries[i].withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: Colors.primaries[i]),
              ),
              title: Text(a['name'] as String),
              subtitle: Text('${a['count']} photos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
