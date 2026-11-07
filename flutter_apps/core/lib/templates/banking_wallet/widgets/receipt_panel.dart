import 'package:flutter/material.dart';

/// A paper-slip container with a scalloped bottom edge, used for anything that
/// reads as a receipt.
class ReceiptPanel extends StatelessWidget {
  const ReceiptPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _ScallopClipper(),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: child,
        ),
      ),
    );
  }
}

class _ScallopClipper extends CustomClipper<Path> {
  const _ScallopClipper();

  static const double _radius = 7;
  static const double _corner = 20;

  @override
  Path getClip(Size size) {
    final teeth = (size.width / (_radius * 2)).floor();
    final tooth = size.width / teeth;
    final path = Path()
      ..moveTo(0, _corner)
      ..quadraticBezierTo(0, 0, _corner, 0)
      ..lineTo(size.width - _corner, 0)
      ..quadraticBezierTo(size.width, 0, size.width, _corner)
      ..lineTo(size.width, size.height - _radius);
    for (var i = teeth; i > 0; i--) {
      path.arcToPoint(
        Offset((i - 1) * tooth, size.height - _radius),
        radius: Radius.circular(tooth / 2),
      );
    }
    return path..close();
  }

  @override
  bool shouldReclip(_ScallopClipper oldClipper) => false;
}

/// A dashed divider that matches the receipt.
class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashPainter(Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + 5, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}
