import 'package:flutter/material.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter(scheme)),
                ),
                // Center pin (floats slightly above center)
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Icon(Icons.location_on,
                      size: 48, color: scheme.primary),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place_outlined, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('221B Baker Street',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          Text('Marylebone, London NW1',
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () {}, child: const Text('Change')),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                      onPressed: () {},
                      child: const Text('Confirm location')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final ColorScheme scheme;
  _GridPainter(this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = scheme.surfaceContainerHighest);
    final road = Paint()
      ..color = scheme.surface
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    for (var y = 60.0; y < size.height; y += 90) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20), road);
    }
    for (var x = 50.0; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x - 20, size.height), road);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
