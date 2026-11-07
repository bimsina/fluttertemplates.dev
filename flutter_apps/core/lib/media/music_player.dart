import 'package:flutter/material.dart';

const _tracks = [
  ('Song Title', 'Artist Name'),
  ('Second Song', 'Another Artist'),
  ('Third Song', 'Artist Name'),
];

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  var _playing = false;
  var _progress = 0.3;
  var _track = 0;

  void _skip(int delta) {
    setState(() {
      _track = (_track + delta) % _tracks.length;
      _progress = 0;
    });
  }

  Widget _artwork(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.music_note, size: size / 3, color: Colors.deepPurple[300]),
    );
  }

  Widget _details(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _tracks[_track].$1,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge,
        ),
        Text(
          _tracks[_track].$2,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1:24', style: textTheme.bodySmall),
            Text('4:12', style: textTheme.bodySmall),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(tooltip: 'Previous track', icon: const Icon(Icons.skip_previous), onPressed: () => _skip(-1)),
            IconButton(
              tooltip: _playing ? 'Pause' : 'Play',
              iconSize: 56,
              icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
              onPressed: () => setState(() => _playing = !_playing),
            ),
            IconButton(tooltip: 'Next track', icon: const Icon(Icons.skip_next), onPressed: () => _skip(1)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(tooltip: 'Queue', icon: const Icon(Icons.playlist_play), onPressed: () => _showDemo(context, 'Queue (demo)')),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sideBySide = constraints.maxWidth > constraints.maxHeight &&
              constraints.maxHeight < 480;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: sideBySide
                  ? Row(
                      spacing: 32,
                      children: [
                        _artwork((constraints.maxHeight - 48).clamp(96, 240)),
                        Expanded(child: _details(context)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 32,
                      children: [_artwork(240), _details(context)],
                    ),
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
