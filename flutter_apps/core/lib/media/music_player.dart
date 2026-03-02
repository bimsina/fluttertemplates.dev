import 'package:flutter/material.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  var _playing = false;
  var _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(icon: const Icon(Icons.playlist_play), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: 240,
            height: 240,
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.music_note, size: 80, color: Colors.deepPurple[300]),
          ),
          Text(
            'Song Title',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text('Artist Name', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1:24', style: Theme.of(context).textTheme.bodySmall),
                    Text('4:12', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous), onPressed: () {}),
              IconButton(
                iconSize: 56,
                icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                onPressed: () => setState(() => _playing = !_playing),
              ),
              IconButton(icon: const Icon(Icons.skip_next), onPressed: () {}),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
