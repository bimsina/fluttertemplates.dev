import 'dart:async';

import 'package:flutter/material.dart';

const _lessonSeconds = 120;

const _lessons = [
  {
    'label': 'Lesson 2: Dart',
    'title': 'Dart Essentials',
    'body': 'Dart is the language behind Flutter. It is type safe, null safe '
        'and compiles to native code as well as JavaScript and WebAssembly.',
  },
  {
    'label': 'Lesson 3: Widgets',
    'title': 'Understanding Flutter Widgets',
    'body': 'Flutter uses a reactive framework for building UIs. '
        'Everything in Flutter is a widget—from structural elements '
        'like padding to stylistic elements like fonts.',
  },
  {
    'label': 'Lesson 4: Layout',
    'title': 'Building Layouts',
    'body': 'Rows, columns and stacks arrange children on screen. Constraints '
        'go down the tree, sizes go up, and parents set the position.',
  },
];

class LessonPlayer extends StatefulWidget {
  const LessonPlayer({super.key});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  var _lesson = 1;
  // Simulated playback position of each lesson, in seconds.
  final _positions = [_lessonSeconds, 42, 0];
  Timer? _timer;

  bool get _playing => _timer != null;
  int get _position => _positions[_lesson];

  void _togglePlay() {
    if (_playing) {
      _pause();
      return;
    }
    setState(() {
      if (_position >= _lessonSeconds) _positions[_lesson] = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    });
  }

  void _tick() {
    setState(() => _positions[_lesson]++);
    if (_position >= _lessonSeconds) _pause();
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _goTo(int lesson) {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _lesson = lesson;
    });
  }

  String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lessons[_lesson];
    final percent = (_position / _lessonSeconds * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(lesson['label']!)),
      body: Column(
        children: [
          Container(
            height: 200,
            color: Colors.grey[800],
            child: Center(
              child: IconButton(
                tooltip: _playing ? 'Pause' : 'Play',
                iconSize: 64,
                color: Colors.white70,
                onPressed: _togglePlay,
                icon: Icon(
                  _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson['title']!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _position.toDouble(),
                    max: _lessonSeconds.toDouble(),
                    padding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setState(() => _positions[_lesson] = v.round()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$percent% complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${_clock(_position)} / ${_clock(_lessonSeconds)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    lesson['body']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _lesson > 0 ? () => _goTo(_lesson - 1) : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                      FilledButton.icon(
                        onPressed: _lesson < _lessons.length - 1
                            ? () => _goTo(_lesson + 1)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
