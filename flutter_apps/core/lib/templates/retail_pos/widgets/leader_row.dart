import 'package:flutter/material.dart';

import 'pos_theme.dart';

/// `Label ........ $0.00`, the row used on the tape and the receipt.
class LeaderRow extends StatelessWidget {
  const LeaderRow({
    super.key,
    required this.label,
    required this.value,
    this.style,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? style;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium!;
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.58),
            child: Text(
              label,
              style: base,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 5),
              child: CustomPaint(
                size: const Size(double.infinity, 2),
                painter: _DotsPainter(theme.colorScheme.outline),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.42),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value, style: (valueStyle ?? base).tabular),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x + 1, size.height / 2), 0.75, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => oldDelegate.color != color;
}
