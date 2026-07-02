import 'package:flutter/material.dart';

class _Step {
  final String title;
  final String time;
  const _Step(this.title, this.time);
}

class CourierTracking extends StatelessWidget {
  const CourierTracking({super.key});

  static const _steps = [
    _Step('Order placed', '2:14 PM'),
    _Step('Preparing your order', '2:22 PM'),
    _Step('Out for delivery', '2:48 PM'),
    _Step('Delivered', 'Est. 3:05 PM'),
  ];
  static const _currentStep = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Track order')),
      body: ListView(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                    child: CustomPaint(painter: _MiniMapPainter(scheme))),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: scheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.delivery_dining,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(child: Text('MJ')),
                title: const Text('Maria Jansen'),
                subtitle: const Text('Your courier · 4.8 ★'),
                trailing: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.call)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (var i = 0; i < _steps.length; i++)
                  _StepRow(
                    step: _steps[i],
                    done: i <= _currentStep,
                    active: i == _currentStep,
                    isLast: i == _steps.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final bool done;
  final bool active;
  final bool isLast;
  const _StepRow({
    required this.step,
    required this.done,
    required this.active,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = done ? scheme.primary : scheme.outlineVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: done ? scheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? Icon(Icons.check,
                        size: 14, color: scheme.onPrimary)
                    : null,
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: color)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: TextStyle(
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.w500)),
                  Text(step.time,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final ColorScheme scheme;
  _MiniMapPainter(this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = scheme.surfaceContainerHighest);
    final route = Paint()
      ..color = scheme.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..cubicTo(size.width * 0.3, size.height * 0.2, size.width * 0.6,
          size.height * 0.9, size.width * 0.9, size.height * 0.3);
    canvas.drawPath(path, route);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 6,
        Paint()..color = scheme.primary);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 6,
        Paint()..color = scheme.tertiary);
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) => false;
}
