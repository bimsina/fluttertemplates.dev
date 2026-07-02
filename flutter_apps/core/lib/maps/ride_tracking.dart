import 'package:flutter/material.dart';

class RideTracking extends StatelessWidget {
  const RideTracking({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RoutePainter(scheme))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CircleAvatar(
                    backgroundColor: scheme.surface,
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_back)),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Arriving in 4 min',
                            style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Text('2.1 mi away',
                          style:
                              TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(radius: 26, child: Text('DK')),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daniel Kessler',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text('Toyota Prius · KTM 4821',
                                style: TextStyle(
                                    color: scheme.onSurfaceVariant)),
                            const Text('4.9 ★'),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.call,
                                color: scheme.onPrimaryContainer)),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.message,
                                color: scheme.onPrimaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Cancel ride')),
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

class _RoutePainter extends CustomPainter {
  final ColorScheme scheme;
  _RoutePainter(this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = scheme.surfaceContainerHighest);

    final road = Paint()
      ..color = scheme.surface
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.42), road);
    canvas.drawLine(Offset(size.width * 0.6, 0),
        Offset(size.width * 0.5, size.height * 0.7), road);

    // Route polyline
    final route = Paint()
      ..color = scheme.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.65)
      ..lineTo(size.width * 0.25, size.height * 0.42)
      ..lineTo(size.width * 0.55, size.height * 0.38)
      ..lineTo(size.width * 0.55, size.height * 0.2);
    canvas.drawPath(path, route);

    // Start dot
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 8,
        Paint()..color = scheme.primary);
    // Car marker
    final carBg = Paint()..color = scheme.primary;
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.2), 12, carBg);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => false;
}
