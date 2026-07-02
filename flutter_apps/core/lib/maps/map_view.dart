import 'package:flutter/material.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MapPainter(scheme)),
          ),
          // Marker pins
          const Positioned(
              top: 180, left: 90, child: _Pin(Icons.local_cafe, Colors.brown)),
          Positioned(
              top: 300,
              right: 80,
              child: _Pin(Icons.restaurant, scheme.primary)),
          const Positioned(
              bottom: 220, left: 140, child: _Pin(Icons.park, Colors.green)),
          // Search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text('Search here',
                            style:
                                TextStyle(color: scheme.onSurfaceVariant)),
                        const Spacer(),
                        const CircleAvatar(radius: 14, child: Text('A', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Recenter + bottom card
          Positioned(
            right: 16,
            bottom: 150,
            child: FloatingActionButton.small(
              onPressed: () {},
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.restaurant,
                      color: scheme.onPrimaryContainer),
                ),
                title: const Text('Blue Fig Bistro'),
                subtitle: const Text('4.6 ★ · 0.4 mi · Open now'),
                trailing: FilledButton(
                    onPressed: () {}, child: const Text('Go')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Pin(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final ColorScheme scheme;
  _MapPainter(this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = scheme.surfaceContainerHighest;
    canvas.drawRect(Offset.zero & size, bg);

    // Green park block
    final park = Paint()..color = Colors.green.withValues(alpha: 0.25);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.45, size.height * 0.5,
                size.width * 0.4, size.height * 0.28),
            const Radius.circular(16)),
        park);

    // Water strip
    final water = Paint()..color = Colors.blue.withValues(alpha: 0.22);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, size.height * 0.12, size.width * 0.3,
                size.height * 0.9),
            const Radius.circular(12)),
        water);

    // Roads
    final road = Paint()
      ..color = scheme.surface
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.35),
        Offset(size.width, size.height * 0.28), road);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.42, size.height), road);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.62, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.78), road);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
