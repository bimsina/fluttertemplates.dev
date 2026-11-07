import 'package:flutter/material.dart';

import 'pos_theme.dart';

/// Paper stock with a torn, saw-tooth edge. Used by the till tape and receipt.
class TornPaper extends StatelessWidget {
  const TornPaper({
    super.key,
    required this.child,
    this.tornTop = false,
    this.tornBottom = true,
    this.elevation = 1.5,
  });

  final Widget child;
  final bool tornTop;
  final bool tornBottom;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PhysicalShape(
      clipper: _TornEdgeClipper(top: tornTop, bottom: tornBottom),
      color: PosTheme.paper(scheme),
      shadowColor: scheme.shadow,
      elevation: elevation,
      child: Padding(
        padding: EdgeInsets.only(
          top: tornTop ? _TornEdgeClipper.toothHeight : 0,
          bottom: tornBottom ? _TornEdgeClipper.toothHeight : 0,
        ),
        child: child,
      ),
    );
  }
}

class _TornEdgeClipper extends CustomClipper<Path> {
  const _TornEdgeClipper({required this.top, required this.bottom});

  static const double toothWidth = 12;
  static const double toothHeight = 6;

  final bool top;
  final bool bottom;

  @override
  Path getClip(Size size) {
    final teeth = (size.width / toothWidth).ceil();
    final step = size.width / teeth;
    final path = Path()..moveTo(0, top ? toothHeight : 0);

    if (top) {
      for (var i = 0; i < teeth; i++) {
        path
          ..lineTo(step * i + step / 2, 0)
          ..lineTo(step * (i + 1), toothHeight);
      }
    } else {
      path.lineTo(size.width, 0);
    }

    if (bottom) {
      path.lineTo(size.width, size.height - toothHeight);
      for (var i = teeth; i > 0; i--) {
        path
          ..lineTo(step * i - step / 2, size.height)
          ..lineTo(step * (i - 1), size.height - toothHeight);
      }
    } else {
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TornEdgeClipper oldClipper) =>
      oldClipper.top != top || oldClipper.bottom != bottom;
}
