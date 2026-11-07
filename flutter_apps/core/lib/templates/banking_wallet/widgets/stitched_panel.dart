import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// The app's signature shape: the front of a leather billfold, with a thumb
/// notch along the top edge and a dashed stitch line inside the border.
class StitchedPanel extends StatelessWidget {
  const StitchedPanel({
    super.key,
    required this.child,
    this.notch = 14,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 22),
  });

  final Widget child;

  /// How deep the thumb notch dips into the top edge. Zero for a straight edge.
  final double notch;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _StitchedPanelPainter(
        fill: scheme.primary,
        stitch: scheme.onPrimary.withValues(alpha: 0.38),
        shadow: scheme.shadow,
        notch: notch,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _StitchedPanelPainter extends CustomPainter {
  const _StitchedPanelPainter({
    required this.fill,
    required this.stitch,
    required this.shadow,
    required this.notch,
  });

  final Color fill;
  final Color stitch;
  final Color shadow;
  final double notch;

  Path _outline(Rect rect, double radius, double dip) {
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;
    final width = rect.width;
    final path = Path()..moveTo(left, top + radius);
    path.quadraticBezierTo(left, top, left + radius, top);
    if (dip > 0) {
      path.lineTo(left + width * 0.3, top);
      path.cubicTo(
        left + width * 0.39,
        top,
        left + width * 0.41,
        top + dip,
        left + width * 0.5,
        top + dip,
      );
      path.cubicTo(
        left + width * 0.59,
        top + dip,
        left + width * 0.61,
        top,
        left + width * 0.7,
        top,
      );
    }
    path.lineTo(right - radius, top);
    path.quadraticBezierTo(right, top, right, top + radius);
    path.lineTo(right, bottom - radius);
    path.quadraticBezierTo(right, bottom, right - radius, bottom);
    path.lineTo(left + radius, bottom);
    path.quadraticBezierTo(left, bottom, left, bottom - radius);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _outline(Offset.zero & size, 28, notch);
    canvas.drawShadow(outer, shadow.withValues(alpha: 0.5), 6, false);
    canvas.drawPath(outer, Paint()..color = fill);

    final inner = _outline((Offset.zero & size).deflate(9), 21, notch);
    final stitchPaint = Paint()
      ..color = stitch
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final PathMetric metric in inner.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 11) {
        canvas.drawPath(
          metric.extractPath(distance, distance + 6),
          stitchPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StitchedPanelPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.stitch != stitch ||
        oldDelegate.shadow != shadow ||
        oldDelegate.notch != notch;
  }
}
