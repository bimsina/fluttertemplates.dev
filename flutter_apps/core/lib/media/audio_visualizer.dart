import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  final _bars = [0.3, 0.6, 0.4, 0.8, 0.5, 0.7, 0.4, 0.6];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Visualizer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _bars.asMap().entries.map((e) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 24,
                  height: 120 * e.value,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.6 + e.value * 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            Icon(Icons.music_note, size: 48, color: Colors.deepPurple[300]),
            const SizedBox(height: 8),
            Text('Playing...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
