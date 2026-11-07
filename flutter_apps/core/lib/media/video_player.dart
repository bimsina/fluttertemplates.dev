import 'dart:async';

import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  static const _duration = Duration(minutes: 8, seconds: 42);

  var _position = const Duration(minutes: 2, seconds: 15);
  Timer? _timer;

  bool get _playing => _timer != null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Simulated: a timer stands in for the real player's position updates.
  void _togglePlaying() {
    setState(() {
      if (_playing) {
        _pause();
      } else {
        if (_position >= _duration) _position = Duration.zero;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    setState(() {
      _position += const Duration(seconds: 1);
      if (_position >= _duration) {
        _position = _duration;
        _pause();
      }
    });
  }

  String _formatTime(Duration d) {
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Title'),
        actions: [
          IconButton(tooltip: 'Fullscreen', icon: const Icon(Icons.fullscreen), onPressed: () => _showDemo(context, 'Fullscreen (demo)')),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _togglePlaying,
            child: Container(
              width: double.infinity,
              height: 220,
              color: Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    top: 8,
                    left: 16,
                    child: Text(
                      'Simulated playback',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  if (!_playing)
                    Padding(
                      // Keeps the icon clear of the control panel below it.
                      padding: const EdgeInsets.only(bottom: 104),
                      child: Icon(Icons.play_circle_fill, size: 72, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white38,
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: _position.inSeconds.toDouble(),
                              max: _duration.inSeconds.toDouble(),
                              onChanged: (v) => setState(
                                () => _position = Duration(seconds: v.round()),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                tooltip: _playing ? 'Pause' : 'Play',
                                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                                color: Colors.white,
                                onPressed: _togglePlaying,
                              ),
                              Text(
                                '${_formatTime(_position)} / ${_formatTime(_duration)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Title',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Channel Name • 12K views', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
