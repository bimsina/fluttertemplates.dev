import 'package:flutter/material.dart';

/// The app's one recurring shape: a key whose teeth carry meaning.
///
/// It is the brand mark, the splash animation and, in `StrengthKey`, the
/// password meter.
class KeyMark extends StatelessWidget {
  const KeyMark({
    super.key,
    required this.color,
    this.height = 32,
    this.teeth = const [0.7, 1, 0.45, 0.85],
    this.toothColor,
    this.socketColor,
  });

  final Color color;
  final double height;

  /// Each tooth's height from 0 to 1.
  final List<double> teeth;

  /// Defaults to [color].
  final Color? toothColor;

  /// When set, full-height outlines are drawn behind the teeth.
  final Color? socketColor;

  /// Width divided by height.
  static const aspectRatio = 2.5;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(height * aspectRatio, height),
        painter: _KeyPainter(
          color: color,
          toothColor: toothColor ?? color,
          socketColor: socketColor,
          teeth: teeth,
        ),
      ),
    );
  }
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter({
    required this.color,
    required this.toothColor,
    required this.socketColor,
    required this.teeth,
  });

  final Color color;
  final Color toothColor;
  final Color? socketColor;
  final List<double> teeth;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final stroke = h * 0.16;
    final radius = h * 0.31;
    final centerY = radius + stroke / 2;
    final shaft = h * 0.16;

    final body = Paint()..color = color;
    canvas.drawCircle(
      Offset(radius + stroke / 2, centerY),
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(radius * 2 + stroke / 2, centerY - shaft / 2, w, centerY + shaft / 2),
        Radius.circular(shaft / 2),
      ),
      body,
    );

    final toothTop = centerY + shaft / 2 - 1;
    final maxTooth = h - toothTop;
    final start = w * 0.46;
    final slot = (w - start) / teeth.length;
    final toothWidth = slot * 0.62;
    final corner = Radius.circular(toothWidth * 0.28);

    for (var i = 0; i < teeth.length; i++) {
      final left = start + slot * i;
      final socket = socketColor;
      if (socket != null) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(left, toothTop, toothWidth, maxTooth),
            bottomLeft: corner,
            bottomRight: corner,
          ),
          Paint()..color = socket,
        );
      }
      final value = teeth[i].clamp(0.0, 1.0);
      if (value == 0) continue;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, toothTop, toothWidth, maxTooth * value),
          bottomLeft: corner,
          bottomRight: corner,
        ),
        Paint()..color = toothColor,
      );
    }
  }

  @override
  bool shouldRepaint(_KeyPainter old) =>
      old.color != color ||
      old.toothColor != toothColor ||
      old.socketColor != socketColor ||
      old.teeth != teeth;
}
