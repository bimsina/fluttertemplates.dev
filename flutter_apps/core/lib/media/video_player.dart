import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  var _playing = false;
  var _progress = 0.25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Title'),
        actions: [
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _playing = !_playing),
            child: Container(
              height: 220,
              color: Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: 72, color: Colors.white.withValues(alpha: 0.9)),
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
                              value: _progress,
                              onChanged: (v) => setState(() => _progress = v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                                color: Colors.white,
                                onPressed: () => setState(() => _playing = !_playing),
                              ),
                              Text('2:15 / 8:42', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
