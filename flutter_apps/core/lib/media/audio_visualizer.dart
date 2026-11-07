import 'dart:math';

import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  static const _barCount = 8;

  late final AnimationController _controller;
  var _playing = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlaying() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  /// Simulated level between 0.15 and 1. Whole-number wave counts make the
  /// loop seamless; feed real amplitude or FFT data here instead.
  double _level(int bar) {
    final phase = _controller.value * 2 * pi;
    final slow = sin(phase * 2 + bar * 0.9);
    final fast = sin(phase * 5 + bar * 2.1);
    return 0.15 + 0.85 * (0.5 + 0.3 * slow + 0.2 * fast);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Visualizer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_barCount, (i) {
                    final level = _level(i);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 24,
                      height: 120 * level,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(
                          alpha: 0.6 + level * 0.4,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 48),
            IconButton.filledTonal(
              iconSize: 32,
              tooltip: _playing ? 'Pause' : 'Play',
              onPressed: _togglePlaying,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(height: 8),
            Text(
              _playing ? 'Playing...' : 'Paused',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Simulated levels, no audio source',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
