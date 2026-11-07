import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum _Mode {
  focus('Focus', 25),
  shortBreak('Short break', 5),
  longBreak('Long break', 15);

  const _Mode(this.label, this.defaultMinutes);
  final String label;
  final int defaultMinutes;
}

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const _roundsPerCycle = 4;

  final _minutes = {for (final m in _Mode.values) m: m.defaultMinutes};
  final _clock = Stopwatch();
  Timer? _ticker;

  var _mode = _Mode.focus;
  var _completedRounds = 0;
  var _focusedMinutes = 0;

  /// Time already banked before the current run, scaled by [_speed].
  var _banked = Duration.zero;
  var _speed = 1;

  Duration get _total => Duration(minutes: _minutes[_mode]!);

  Duration get _elapsed => _banked + _clock.elapsed * _speed;

  Duration get _remaining {
    final left = _total - _elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool get _running => _clock.isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    _clock.start();
    // Reading the stopwatch on every tick keeps the display honest even when a
    // backgrounded browser tab throttles this timer.
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_remaining == Duration.zero) {
        _finish();
      } else {
        setState(() {});
      }
    });
    setState(() {});
  }

  void _pause() {
    _bank();
    setState(() {});
  }

  void _bank() {
    _banked = _elapsed;
    _clock
      ..stop()
      ..reset();
    _ticker?.cancel();
  }

  void _reset() {
    _bank();
    setState(() => _banked = Duration.zero);
  }

  void _switchTo(_Mode mode) {
    _reset();
    setState(() => _mode = mode);
  }

  void _finish({bool skipped = false}) {
    final wasFocus = _mode == _Mode.focus;
    if (wasFocus && !skipped) {
      _completedRounds++;
      _focusedMinutes += _minutes[_Mode.focus]!;
    }
    final next = !wasFocus
        ? _Mode.focus
        : _completedRounds > 0 && _completedRounds % _roundsPerCycle == 0
            ? _Mode.longBreak
            : _Mode.shortBreak;
    final finishedLabel = _mode.label;
    _switchTo(next);
    if (!skipped && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$finishedLabel finished. Next: ${next.label}.'),
            action: SnackBarAction(label: 'Start', onPressed: _start),
          ),
        );
    }
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in _Mode.values)
                  Row(
                    children: [
                      Expanded(child: Text(mode.label)),
                      IconButton(
                        tooltip: 'Less',
                        onPressed: _minutes[mode]! <= 1
                            ? null
                            : () => _changeMinutes(mode, -1, setSheet),
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          '${_minutes[mode]} min',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'More',
                        onPressed: _minutes[mode]! >= 90
                            ? null
                            : () => _changeMinutes(mode, 1, setSheet),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Preview at 60x speed'),
                  subtitle: const Text('Watch a full round in under a minute'),
                  value: _speed > 1,
                  onChanged: (fast) {
                    // Bank first so past time is not rescaled by the new speed.
                    final wasRunning = _running;
                    _bank();
                    _speed = fast ? 60 : 1;
                    if (wasRunning) _start();
                    setSheet(() {});
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeMinutes(_Mode mode, int by, StateSetter setSheet) {
    setSheet(() => _minutes[mode] = _minutes[mode]! + by);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final remaining = _remaining;
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final progress = 1 - remaining.inMilliseconds / _total.inMilliseconds;
    final isFocus = _mode == _Mode.focus;
    final filledRounds = _completedRounds % _roundsPerCycle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        actions: [
          IconButton(
            tooltip: 'Timer settings',
            onPressed: _openSettings,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final mode in _Mode.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(mode.label),
                      showCheckmark: false,
                      selected: mode == _mode,
                      onSelected: (_) => _switchTo(mode),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: SizedBox.square(
              dimension: 240,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  track: scheme.surfaceContainerHighest,
                  color: isFocus ? scheme.primary : scheme.tertiary,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$minutes:$seconds',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        _running
                            ? _mode.label
                            : _elapsed > Duration.zero
                                ? 'Paused'
                                : 'Ready',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            label: '$filledRounds of $_roundsPerCycle rounds done',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _roundsPerCycle; i++)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < filledRounds
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Reset',
                onPressed: _elapsed > Duration.zero ? _reset : null,
                icon: const Icon(Icons.replay),
              ),
              const SizedBox(width: 12),
              SizedBox.square(
                dimension: 72,
                child: IconButton.filled(
                  tooltip: _running ? 'Pause' : 'Start',
                  iconSize: 36,
                  onPressed: _running ? _pause : _start,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Skip',
                onPressed: () => _finish(skipped: true),
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$_completedRounds rounds, $_focusedMinutes focused minutes today',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });

  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - stroke / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
