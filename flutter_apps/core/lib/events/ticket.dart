import 'dart:math';
import 'package:flutter/material.dart';

const _notchRadius = 10.0;

class Ticket extends StatelessWidget {
  const Ticket({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your ticket')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 320,
            child: Column(
              children: [
                // The ticket is two clipped halves that meet at the perforation,
                // so each notch is a real hole whatever sits behind the ticket.
                ClipPath(
                  clipper: const _TicketHalfClipper(notchAtBottom: true),
                  child: ColoredBox(
                    color: scheme.surfaceContainerHigh,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: scheme.primary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Indie Nights Live',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                      color: scheme.onPrimary,
                                      fontWeight: FontWeight.bold)),
                              Text('Fri, Jul 12 · 8:00 PM',
                                  style: TextStyle(
                                      color: scheme.onPrimary
                                          .withValues(alpha: 0.85))),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(child: _info(scheme, 'Section', 'GA')),
                              Expanded(child: _info(scheme, 'Row', 'B')),
                              Expanded(child: _info(scheme, 'Seat', '14')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ClipPath(
                  clipper: const _TicketHalfClipper(notchAtBottom: false),
                  child: ColoredBox(
                    color: scheme.surfaceContainerHigh,
                    child: Column(
                      children: [
                        // Perforated divider
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: _notchRadius + 6),
                          child: CustomPaint(
                              painter:
                                  _DashedLinePainter(scheme.outlineVariant),
                              size: const Size(double.infinity, 1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CustomPaint(painter: _QrPainter()),
                              ),
                              const SizedBox(height: 12),
                              Text('TKT-9F2A-4821',
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: scheme.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text('Sample QR, not scannable',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(ColorScheme scheme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}

/// Rounds the two outer corners of one ticket half and cuts a half-circle
/// from each end of the edge it shares with the other half.
class _TicketHalfClipper extends CustomClipper<Path> {
  final bool notchAtBottom;
  const _TicketHalfClipper({required this.notchAtBottom});

  @override
  Path getClip(Size size) {
    const corner = Radius.circular(20);
    final rect = Offset.zero & size;
    final body = Path()
      ..addRRect(notchAtBottom
          ? RRect.fromRectAndCorners(rect, topLeft: corner, topRight: corner)
          : RRect.fromRectAndCorners(rect,
              bottomLeft: corner, bottomRight: corner));

    final y = notchAtBottom ? size.height : 0.0;
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: _notchRadius))
      ..addOval(
          Rect.fromCircle(center: Offset(size.width, y), radius: _notchRadius));

    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(_TicketHalfClipper oldClipper) =>
      oldClipper.notchAtBottom != notchAtBottom;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dash = 6.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash * 2;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, white);
    const n = 21;
    final cell = size.width / n;
    final rng = Random(42);
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (rng.nextBool()) {
          canvas.drawRect(
              Rect.fromLTWH(c * cell, r * cell, cell, cell), paint);
        }
      }
    }
    // Finder squares
    void finder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, cell * 7, cell * 7), paint);
      canvas.drawRect(
          Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5), white);
      canvas.drawRect(
          Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3),
          paint);
    }

    finder(0, 0);
    finder(cell * (n - 7), 0);
    finder(0, cell * (n - 7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
