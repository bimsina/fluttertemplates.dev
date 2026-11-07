import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Photo'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(tooltip: 'Share', icon: const Icon(Icons.share), onPressed: () => _showDemo(context, 'Share (demo)')),
          IconButton(tooltip: 'Download', icon: const Icon(Icons.download), onPressed: () => _showDemo(context, 'Download (demo)')),
        ],
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(painter: _PlaceholderPhotoPainter()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a simple landscape so the viewer has something to zoom into without
/// needing a network image or bundled asset.
class _PlaceholderPhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF27408B), Color(0xFFE98B6D), Color(0xFFFBD38D)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * 0.68, size.height * 0.42),
      size.height * 0.11,
      Paint()..color = const Color(0xFFFFF3D6),
    );

    void hill(double left, double peak, double right, Color color) {
      final path = Path()
        ..moveTo(0, size.height * left)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * peak,
          size.width,
          size.height * right,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    hill(0.72, 0.42, 0.66, const Color(0xFF5B4A7A));
    hill(0.82, 0.62, 0.90, const Color(0xFF2F2B4A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
