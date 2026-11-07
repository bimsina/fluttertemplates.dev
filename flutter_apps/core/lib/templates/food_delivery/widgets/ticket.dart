import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../models/order.dart';

/// Receipt paper with torn zig-zag top and bottom edges.
class Ticket extends StatelessWidget {
  const Ticket({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PhysicalShape(
      clipper: const _TicketClipper(),
      color: scheme.surfaceContainerHigh,
      shadowColor: scheme.shadow,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
        child: child,
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  static const _tooth = 12.0;
  static const _depth = 6.0;

  @override
  Path getClip(Size size) {
    final teeth = (size.width / _tooth).floor().clamp(1, 400);
    final step = size.width / teeth;
    final path = Path()..moveTo(0, _depth);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(step * i + step / 2, 0)
        ..lineTo(step * (i + 1), _depth);
    }
    path.lineTo(size.width, size.height - _depth);
    for (var i = teeth; i > 0; i--) {
      path
        ..lineTo(step * i - step / 2, size.height)
        ..lineTo(step * (i - 1), size.height - _depth);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashPainter(Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}

/// A money amount that counts to its new value instead of jumping.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({super.key, required this.cents, this.style});

  final int cents;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: cents.toDouble()),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        formatMoney(value.round()),
        style: (style ?? const TextStyle()).copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    required this.cents,
    this.accent = false,
    this.freeWhenZero = false,
  });

  final String label;
  final int cents;
  final bool accent;
  final bool freeWhenZero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: accent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      fontWeight: accent ? FontWeight.w700 : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          if (freeWhenZero && cents == 0)
            Text('Free', style: style)
          else
            AnimatedMoney(cents: cents, style: style),
        ],
      ),
    );
  }
}

/// The full price breakdown, shared by cart, checkout and order details.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.prices,
    this.promoLabel,
    this.showTip = true,
  });

  final PriceBreakdown prices;
  final String? promoLabel;
  final bool showTip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Ticket(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PriceRow(label: 'Subtotal', cents: prices.subtotalCents),
          PriceRow(
            label: 'Delivery',
            cents: prices.deliveryFeeCents,
            freeWhenZero: true,
          ),
          PriceRow(label: 'Service fee', cents: prices.serviceFeeCents),
          PriceRow(label: 'Tax', cents: prices.taxCents),
          if (showTip) PriceRow(label: 'Tip', cents: prices.tipCents),
          if (prices.discountCents > 0)
            PriceRow(
              label: promoLabel ?? 'Discount',
              cents: -prices.discountCents,
              accent: true,
            ),
          const DashedDivider(),
          Row(
            children: [
              Expanded(child: Text('Total', style: theme.textTheme.titleLarge)),
              const SizedBox(width: 12),
              AnimatedMoney(
                cents: showTip
                    ? prices.totalCents
                    : prices.totalCents - prices.tipCents,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
