import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// Stylized city map with the courier moving along the route.
///
/// [progress] is the delivery progress from 0 to 1. A real app would swap this
/// for a map SDK and feed it courier coordinates instead.
class RouteMap extends StatefulWidget {
  const RouteMap({super.key, required this.progress});

  /// Share of the delivery spent in the kitchen, before the courier moves.
  static const pickupAt = 0.4;

  final double progress;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: widget.progress),
      duration: const Duration(milliseconds: 300),
      builder: (context, progress, _) {
        final travelled =
            ((progress - RouteMap.pickupAt) / (1 - RouteMap.pickupAt)).clamp(
              0.0,
              1.0,
            );
        return RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _MapPainter(
              scheme: scheme,
              travelled: travelled,
              pulse: _pulse,
            ),
          ),
        );
      },
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.scheme,
    required this.travelled,
    required this.pulse,
  }) : super(repaint: pulse);

  final ColorScheme scheme;
  final double travelled;
  final Animation<double> pulse;

  // Street centerlines, as fractions of the map size.
  static const _columns = [0.14, 0.38, 0.62, 0.86];
  static const _rows = [0.18, 0.5, 0.82];

  // The route turns only at intersections of the streets above.
  static const _route = [
    Offset(0.14, 0.18),
    Offset(0.38, 0.18),
    Offset(0.38, 0.5),
    Offset(0.62, 0.5),
    Offset(0.62, 0.82),
    Offset(0.86, 0.82),
  ];

  Offset _at(Offset fraction, Size size) =>
      Offset(fraction.dx * size.width, fraction.dy * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = scheme.surfaceContainer,
    );
    _blocks(canvas, size);
    _streets(canvas, size);

    final route = Path();
    for (var i = 0; i < _route.length; i++) {
      final point = _at(_route[i], size);
      i == 0
          ? route.moveTo(point.dx, point.dy)
          : route.lineTo(point.dx, point.dy);
    }
    final PathMetric metric = route.computeMetrics().first;
    final distance = metric.length * travelled;

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      route,
      line..color = scheme.outline.withValues(alpha: 0.55),
    );
    if (distance > 0) {
      canvas.drawPath(
        metric.extractPath(0, distance),
        line..color = scheme.primary,
      );
    }

    final start = _at(_route.first, size);
    final end = _at(_route.last, size);
    _pin(
      canvas,
      start,
      Icons.restaurant_rounded,
      scheme.secondary,
      scheme.onSecondary,
    );
    _pin(canvas, end, Icons.home_rounded, scheme.tertiary, scheme.onTertiary);

    final courier = metric.getTangentForOffset(distance)?.position ?? start;
    _courier(canvas, courier);
  }

  void _blocks(Canvas canvas, Size size) {
    final block = Paint()..color = scheme.surfaceContainerHigh;
    final park = Paint()..color = scheme.tertiaryContainer;
    final edgesX = [0.0, ..._columns, 1.0];
    final edgesY = [0.0, ..._rows, 1.0];
    const gap = 9.0;
    for (var x = 0; x < edgesX.length - 1; x++) {
      for (var y = 0; y < edgesY.length - 1; y++) {
        final rect = Rect.fromLTRB(
          edgesX[x] * size.width + gap,
          edgesY[y] * size.height + gap,
          edgesX[x + 1] * size.width - gap,
          edgesY[y + 1] * size.height - gap,
        );
        if (rect.width <= 0 || rect.height <= 0) continue;
        final isPark = (x == 3 && y == 1) || (x == 1 && y == 2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          isPark ? park : block,
        );
      }
    }
  }

  void _streets(Canvas canvas, Size size) {
    final street = Paint()
      ..color = scheme.surfaceContainerLowest
      ..strokeWidth = 10;
    for (final x in _columns) {
      canvas.drawLine(
        Offset(x * size.width, 0),
        Offset(x * size.width, size.height),
        street,
      );
    }
    for (final y in _rows) {
      canvas.drawLine(
        Offset(0, y * size.height),
        Offset(size.width, y * size.height),
        street,
      );
    }
  }

  void _pin(Canvas canvas, Offset at, IconData icon, Color fill, Color ink) {
    canvas.drawCircle(at, 17, Paint()..color = scheme.surface);
    canvas.drawCircle(at, 14, Paint()..color = fill);
    _icon(canvas, at, icon, 16, ink);
  }

  void _courier(Canvas canvas, Offset at) {
    final wave = math.sin(pulse.value * math.pi);
    canvas.drawCircle(
      at,
      18 + pulse.value * 14,
      Paint()..color = scheme.primary.withValues(alpha: 0.28 * wave),
    );
    canvas.drawCircle(at, 19, Paint()..color = scheme.surface);
    canvas.drawCircle(at, 16, Paint()..color = scheme.primary);
    _icon(canvas, at, Icons.delivery_dining_rounded, 20, scheme.onPrimary);
  }

  void _icon(
    Canvas canvas,
    Offset at,
    IconData icon,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: color,
        ),
      ),
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.travelled != travelled || oldDelegate.scheme != scheme;
}
