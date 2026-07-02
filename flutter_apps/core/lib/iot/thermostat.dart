import 'dart:math';
import 'package:flutter/material.dart';

class Thermostat extends StatefulWidget {
  const Thermostat({super.key});

  @override
  State<Thermostat> createState() => _ThermostatState();
}

class _ThermostatState extends State<Thermostat> {
  double _target = 21;
  int _mode = 0; // 0 heat, 1 cool, 2 auto
  static const _min = 10.0;
  static const _max = 30.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = (_target - _min) / (_max - _min);

    return Scaffold(
      appBar: AppBar(title: const Text('Thermostat')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: _DialPainter(t, scheme),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${_target.toStringAsFixed(0)}°',
                          style: theme.textTheme.displayMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Target · now 20°',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: () => setState(
                      () => _target = (_target - 1).clamp(_min, _max)),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 40),
                IconButton.filledTonal(
                  onPressed: () => setState(
                      () => _target = (_target + 1).clamp(_min, _max)),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Spacer(),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.local_fire_department),
                    label: Text('Heat')),
                ButtonSegment(
                    value: 1, icon: Icon(Icons.ac_unit), label: Text('Cool')),
                ButtonSegment(
                    value: 2, icon: Icon(Icons.autorenew), label: Text('Auto')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double t; // 0..1
  final ColorScheme scheme;
  _DialPainter(this.t, this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;
    const startAngle = pi * 0.75;
    const sweep = pi * 1.5;

    final track = Paint()
      ..color = scheme.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep, false, track);

    final progress = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep * t, false, progress);

    // Knob
    final knobAngle = startAngle + sweep * t;
    final knob = Offset(center.dx + radius * cos(knobAngle),
        center.dy + radius * sin(knobAngle));
    canvas.drawCircle(knob, 11, Paint()..color = scheme.primary);
    canvas.drawCircle(knob, 5, Paint()..color = scheme.onPrimary);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.t != t;
}
