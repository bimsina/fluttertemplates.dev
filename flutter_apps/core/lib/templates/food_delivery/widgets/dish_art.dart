import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/restaurant.dart';

/// A top-down plate drawn entirely with canvas calls, so the template ships
/// with no image assets. Every color comes from the color scheme, which means
/// the same dish takes on the palette of the restaurant serving it.
///
/// A null [kind] draws an empty plate with cutlery, used by the empty states.
class DishArt extends StatelessWidget {
  const DishArt({super.key, required this.kind, this.size = 72, this.scheme});

  final DishKind? kind;
  final double size;

  /// Pass this when the art sits inside a Hero, because a Hero flight does
  /// not inherit the Theme of the screen it left.
  final ColorScheme? scheme;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _DishPainter(kind, scheme ?? Theme.of(context).colorScheme),
      ),
    );
  }
}

class _DishPainter extends CustomPainter {
  _DishPainter(this.kind, this.scheme);

  final DishKind? kind;
  final ColorScheme scheme;

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is drawn on a 100 x 100 grid centered at (0, 0).
    final scale = size.shortestSide / 100;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    _plate(canvas);
    switch (kind) {
      case null:
        _emptyPlate(canvas);
      case DishKind.pizza:
        _pizza(canvas);
      case DishKind.ramen:
        _ramen(canvas);
      case DishKind.burger:
        _burger(canvas);
      case DishKind.taco:
        _tacos(canvas);
      case DishKind.salad:
        _salad(canvas);
      case DishKind.sushi:
        _sushi(canvas);
      case DishKind.curry:
        _curry(canvas);
      case DishKind.cake:
        _cake(canvas);
      case DishKind.drink:
        _drink(canvas);
      case DishKind.fries:
        _fries(canvas);
    }
    canvas.restore();
  }

  Offset _polar(double radius, double angle) =>
      Offset(math.cos(angle) * radius, math.sin(angle) * radius);

  void _plate(Canvas canvas) {
    canvas.drawCircle(
      const Offset(0, 2.5),
      48,
      _fill(scheme.shadow.withValues(alpha: 0.18)),
    );
    canvas.drawCircle(Offset.zero, 48, _fill(scheme.surfaceContainerLowest));
    canvas.drawCircle(
      Offset.zero,
      41,
      _stroke(scheme.outlineVariant.withValues(alpha: 0.6), 0.8),
    );
  }

  void _emptyPlate(Canvas canvas) {
    final line = _stroke(scheme.outline, 3);
    canvas.drawCircle(Offset.zero, 24, _stroke(scheme.outlineVariant, 1.2));
    // Fork.
    canvas.drawLine(const Offset(-11, -16), const Offset(-11, 17), line);
    for (final x in [-15.0, -11.0, -7.0]) {
      canvas.drawLine(
        Offset(x, -17),
        Offset(x, -7),
        _stroke(scheme.outline, 2),
      );
    }
    canvas.drawLine(
      const Offset(-15, -7),
      const Offset(-7, -7),
      _stroke(scheme.outline, 2),
    );
    // Knife.
    canvas.drawLine(const Offset(11, -17), const Offset(11, 17), line);
    canvas.drawPath(
      Path()
        ..moveTo(11, -17)
        ..quadraticBezierTo(18, -10, 15, 1)
        ..lineTo(11, 1)
        ..close(),
      _fill(scheme.outline),
    );
  }

  void _pizza(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 37, _fill(scheme.tertiaryContainer));
    canvas.drawCircle(Offset.zero, 32, _fill(scheme.primary));
    canvas.drawCircle(Offset.zero, 29, _fill(scheme.primaryContainer));
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + 0.5;
      canvas.drawCircle(_polar(20, angle), 5, _fill(scheme.primary));
    }
    canvas.drawCircle(Offset.zero, 5, _fill(scheme.primary));
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi / 3 + 0.05;
      canvas.drawLine(
        _polar(37, angle),
        _polar(-37, angle),
        _stroke(scheme.surfaceContainerLowest, 1.1),
      );
    }
    for (final angle in [1.3, 3.6, 5.3]) {
      canvas.save();
      canvas.translate(_polar(12, angle).dx, _polar(12, angle).dy);
      canvas.rotate(angle);
      canvas.drawOval(
        const Rect.fromLTWH(-4.5, -2, 9, 4),
        _fill(scheme.tertiary),
      );
      canvas.restore();
    }
  }

  void _ramen(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 38, _fill(scheme.primary));
    canvas.drawCircle(Offset.zero, 33, _fill(scheme.tertiaryContainer));
    final noodle = _stroke(scheme.tertiary, 2.2);
    for (var i = 0; i < 5; i++) {
      final y = -16.0 + i * 6.5;
      canvas.drawPath(
        Path()
          ..moveTo(-26, y + 8)
          ..cubicTo(-16, y - 6, -8, y + 12, 0, y + 2)
          ..cubicTo(6, y - 5, 10, y + 8, 12, y + 4),
        noodle,
      );
    }
    // Soft egg.
    canvas.drawCircle(
      const Offset(17, -12),
      11,
      _fill(scheme.surfaceContainerLowest),
    );
    canvas.drawCircle(const Offset(17, -12), 5.5, _fill(scheme.primary));
    // Nori.
    canvas.save();
    canvas.translate(18, 13);
    canvas.rotate(0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, -11, 14, 22),
        const Radius.circular(1.5),
      ),
      _fill(scheme.onPrimaryContainer),
    );
    canvas.restore();
    for (final offset in const [
      Offset(-14, -20),
      Offset(-5, 23),
      Offset(-20, 16),
    ]) {
      canvas.drawCircle(offset, 2.4, _stroke(scheme.primary, 1.3));
    }
  }

  void _burger(Canvas canvas) {
    final frill = Path();
    for (var i = 0; i <= 72; i++) {
      final angle = i / 72 * math.pi * 2;
      final point = _polar(36 + math.sin(angle * 12) * 2.2, angle);
      i == 0
          ? frill.moveTo(point.dx, point.dy)
          : frill.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(frill..close(), _fill(scheme.tertiary));
    canvas.drawCircle(Offset.zero, 32, _fill(scheme.primary));
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 25),
      math.pi * 1.05,
      math.pi * 0.55,
      false,
      _stroke(scheme.primaryContainer.withValues(alpha: 0.7), 3.5),
    );
    const seeds = [
      (-12.0, -8.0, 0.4),
      (-2.0, -16.0, -0.6),
      (9.0, -10.0, 1.1),
      (15.0, 2.0, 0.2),
      (5.0, 5.0, -0.9),
      (-7.0, 7.0, 0.9),
      (-17.0, 6.0, -0.3),
      (-1.0, 18.0, 0.6),
      (11.0, 15.0, -0.4),
    ];
    for (final (x, y, angle) in seeds) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawOval(
        const Rect.fromLTWH(-2.6, -1.4, 5.2, 2.8),
        _fill(scheme.surfaceContainerLowest),
      );
      canvas.restore();
    }
  }

  void _tacos(Canvas canvas) {
    void taco(Offset at, double rotation) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(rotation);
      // Filling peeks out above the folded tortilla.
      canvas.drawCircle(const Offset(-13, -3), 6, _fill(scheme.tertiary));
      canvas.drawCircle(const Offset(-3, -6), 6, _fill(scheme.primary));
      canvas.drawCircle(const Offset(8, -5), 6, _fill(scheme.tertiary));
      canvas.drawCircle(const Offset(15, -1), 4.5, _fill(scheme.primary));
      final shell = Path()
        ..moveTo(-25, 0)
        ..arcToPoint(
          const Offset(25, 0),
          radius: const Radius.circular(25),
          clockwise: false,
        )
        ..close();
      canvas.drawPath(shell, _fill(scheme.primaryContainer));
      canvas.drawPath(shell, _stroke(scheme.primary, 1.4));
      for (final dot in const [Offset(-9, 8), Offset(4, 13), Offset(11, 6)]) {
        canvas.drawCircle(dot, 1.2, _fill(scheme.primary));
      }
      canvas.restore();
    }

    taco(const Offset(-3, -17), -0.2);
    taco(const Offset(3, 7), 0.16);
  }

  void _salad(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 38, _fill(scheme.primaryContainer));
    final greens = [scheme.tertiary, scheme.primary, scheme.secondary];
    for (var i = 0; i < 16; i++) {
      final angle = i * 2.399;
      final radius = 7 + (i % 4) * 7.0;
      final at = _polar(radius, angle);
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(angle + 0.7);
      canvas.drawOval(
        const Rect.fromLTWH(-10, -5, 20, 10),
        _fill(greens[i % 3]),
      );
      canvas.drawLine(
        const Offset(-7, 0),
        const Offset(7, 0),
        _stroke(scheme.primaryContainer.withValues(alpha: 0.5), 0.7),
      );
      canvas.restore();
    }
    for (final dot in const [Offset(-12, -11), Offset(13, -6), Offset(1, 15)]) {
      canvas.drawCircle(dot, 6, _fill(scheme.tertiaryContainer));
      canvas.drawCircle(dot, 2.4, _fill(scheme.tertiary));
    }
  }

  void _sushi(Canvas canvas) {
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 2; col++) {
        final center = Offset(col * 26.0 - 13, row * 22.0 - 22);
        canvas.drawCircle(center, 12, _fill(scheme.onPrimaryContainer));
        canvas.drawCircle(center, 9.5, _fill(scheme.primaryContainer));
        canvas.drawCircle(
          center,
          4.5,
          _fill((row + col).isEven ? scheme.primary : scheme.tertiary),
        );
      }
    }
  }

  void _curry(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 38, _fill(scheme.primary));
    canvas.drawCircle(Offset.zero, 33, _fill(scheme.tertiaryContainer));
    final rice = Path()
      ..moveTo(-6, -33)
      ..quadraticBezierTo(14, 0, -6, 33)
      ..arcToPoint(const Offset(-6, -33), radius: const Radius.circular(33))
      ..close();
    canvas.drawPath(rice, _fill(scheme.surfaceContainerLowest));
    for (var i = 0; i < 14; i++) {
      final at = Offset(-26 + (i % 4) * 7.0, -18 + (i ~/ 4) * 12.0);
      canvas.drawOval(
        Rect.fromCenter(center: at, width: 4, height: 1.7),
        _fill(scheme.outlineVariant),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(9, -15)
        ..cubicTo(24, -13, 25, 7, 13, 8)
        ..cubicTo(4, 9, 6, -3, 14, -2),
      _stroke(scheme.primaryContainer, 2.6),
    );
    for (final dot in const [Offset(14, 18), Offset(22, 13), Offset(8, 22)]) {
      canvas.drawCircle(dot, 1.8, _fill(scheme.tertiary));
    }
  }

  void _cake(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 35, _fill(scheme.tertiaryContainer));
    canvas.drawCircle(Offset.zero, 30, _fill(scheme.primaryContainer));
    // A slice has been taken out.
    final cut = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 36),
        -0.5,
        0.95,
        false,
      )
      ..close();
    canvas.drawPath(cut, _fill(scheme.surfaceContainerLowest));
    for (var i = 0; i < 9; i++) {
      final angle = 0.75 + i * 0.6;
      canvas.drawCircle(
        _polar(24, angle),
        4.4,
        _fill(i.isEven ? scheme.primary : scheme.tertiary),
      );
    }
    canvas.drawCircle(const Offset(-6, 4), 6.5, _fill(scheme.primary));
  }

  void _drink(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 31, _fill(scheme.outlineVariant));
    canvas.drawCircle(Offset.zero, 28, _fill(scheme.primary));
    for (final (x, y, angle) in const [
      (-10.0, -8.0, 0.3),
      (9.0, -12.0, 0.9),
      (-3.0, 11.0, 1.4),
    ]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-7, -7, 14, 14),
          const Radius.circular(3),
        ),
        _fill(scheme.primaryContainer.withValues(alpha: 0.85)),
      );
      canvas.restore();
    }
    canvas.drawLine(
      const Offset(4, 4),
      const Offset(32, 30),
      _stroke(scheme.tertiary, 4),
    );
  }

  void _fries(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 37, _fill(scheme.primaryContainer));
    for (var i = 0; i < 18; i++) {
      final angle = i * 2.399;
      final at = _polar(6 + (i % 5) * 5.5, angle);
      canvas.save();
      canvas.translate(at.dx - 5, at.dy);
      canvas.rotate(angle * 1.7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-15, -2.4, 30, 4.8),
          const Radius.circular(1.4),
        ),
        _fill(i.isEven ? scheme.tertiary : scheme.tertiaryContainer),
      );
      canvas.restore();
    }
    canvas.drawCircle(
      const Offset(22, 20),
      13,
      _fill(scheme.surfaceContainerLowest),
    );
    canvas.drawCircle(const Offset(22, 20), 10, _fill(scheme.primary));
  }

  @override
  bool shouldRepaint(_DishPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.scheme != scheme;
}
