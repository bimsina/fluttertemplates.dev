import 'dart:async';

import 'package:flutter/material.dart';

class _Episode {
  final String title;
  final Duration duration;
  final String date;
  const _Episode(this.title, this.duration, this.date);
}

const _episodes = [
  _Episode('Episode 1: Intro', Duration(minutes: 45, seconds: 12), 'Mar 1'),
  _Episode('Episode 2: Basics', Duration(minutes: 52, seconds: 30), 'Feb 28'),
  _Episode('Episode 3: Advanced', Duration(hours: 1, minutes: 5), 'Feb 25'),
];

String _formatTime(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return d.inHours > 0 ? '${d.inHours}:$minutes:$seconds' : '$minutes:$seconds';
}

class PodcastPlayer extends StatefulWidget {
  const PodcastPlayer({super.key});

  @override
  State<PodcastPlayer> createState() => _PodcastPlayerState();
}

class _PodcastPlayerState extends State<PodcastPlayer> {
  var _current = 0;
  var _position = Duration.zero;
  Timer? _timer;

  bool get _playing => _timer != null;
  _Episode get _episode => _episodes[_current];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Simulated: a timer stands in for your audio plugin's position stream.
  void _play() {
    if (_position >= _episode.duration) _position = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    setState(() {
      _position += const Duration(seconds: 1);
      if (_position >= _episode.duration) {
        _position = _episode.duration;
        _pause();
      }
    });
  }

  void _togglePlaying() {
    setState(() => _playing ? _pause() : _play());
  }

  void _selectEpisode(int index) {
    setState(() {
      _pause();
      _current = index;
      _position = Duration.zero;
      _play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast')),
      body: ListView(
        children: [
          Container(
            height: 220,
            color: Colors.amber.withValues(alpha: 0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.podcasts, size: 80, color: Colors.amber[700]),
                const SizedBox(height: 12),
                Text(
                  'Tech Talk Podcast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Host: Jane Doe', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          ListTile(
            leading: IconButton.filledTonal(
              tooltip: _playing ? 'Pause' : 'Play',
              onPressed: _togglePlaying,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            title: Text(_playing ? 'Now Playing' : 'Paused'),
            subtitle: Text(_episode.title),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _episode.duration.inSeconds.toDouble(),
              onChanged: (v) => setState(
                () => _position = Duration(seconds: v.round()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position)),
                Text('Simulated playback',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(_formatTime(_episode.duration)),
              ],
            ),
          ),
          const Divider(),
          for (var i = 0; i < _episodes.length; i++)
            ListTile(
              leading: const Icon(Icons.podcasts),
              title: Text(_episodes[i].title),
              subtitle: Text(
                '${_formatTime(_episodes[i].duration)} • ${_episodes[i].date}',
              ),
              trailing: const Icon(Icons.download),
              selected: i == _current,
              onTap: () => _selectEpisode(i),
            ),
        ],
      ),
    );
  }
}
