import 'package:flutter/material.dart';

const _tracks = [
  {'title': 'Track One', 'artist': 'Artist A', 'duration': '3:42'},
  {'title': 'Track Two', 'artist': 'Artist B', 'duration': '4:15'},
  {'title': 'Track Three', 'artist': 'Artist A', 'duration': '2:58'},
  {'title': 'Track Four', 'artist': 'Artist C', 'duration': '5:20'},
];

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  int? _playing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Playlist')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 180,
              color: Colors.indigo.withValues(alpha: 0.3),
              child: Center(
                child: Icon(Icons.queue_music, size: 64, color: Colors.indigo[300]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('${_tracks.length} songs', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final t = _tracks[i];
                return ListTile(
                  leading: Text('${i + 1}', style: Theme.of(context).textTheme.titleMedium),
                  title: Text(t['title'] as String),
                  subtitle: Text(t['artist'] as String),
                  trailing: Text(t['duration'] as String),
                  selected: _playing == i,
                  onTap: () => setState(() => _playing = i),
                );
              },
              childCount: _tracks.length,
            ),
          ),
        ],
      ),
    );
  }
}
