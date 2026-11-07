import 'dart:math';

import 'package:flutter/material.dart';

import '../models/bank_card.dart';
import 'wallet_theme.dart';

/// A payment card, laid out on a fixed design canvas and scaled to fit, so it
/// keeps its proportions from a 320px phone up to a tablet.
class BankCardView extends StatelessWidget {
  const BankCardView({
    super.key,
    required this.card,
    required this.variant,
    this.revealed = false,
  });

  static const double aspectRatio = 340 / 214;

  final BankCard card;

  /// Picks the card's color, so that neighbors in a list look different.
  final int variant;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final frozen = card.isFrozen;
    final (start, end, foreground) = switch (variant % 2) {
      0 => (
        scheme.primary,
        Color.lerp(scheme.primary, scheme.tertiary, 0.7)!,
        scheme.onPrimary,
      ),
      _ => (
        scheme.tertiary,
        Color.lerp(scheme.tertiary, scheme.secondary, 0.6)!,
        scheme.onTertiary,
      ),
    };
    final ink = frozen ? scheme.onSurfaceVariant : foreground;
    final showDetails = revealed && !frozen;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: FittedBox(
        child: MediaQuery.withNoTextScaling(
          child: SizedBox(
            width: 340,
            height: 214,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: frozen
                      ? [
                          scheme.surfaceContainerHighest,
                          scheme.surfaceContainerHigh,
                        ]
                      : [start, end],
                ),
              ),
              child: CustomPaint(
                painter: _CardPatternPainter(
                  color: ink.withValues(alpha: 0.1),
                  frozen: frozen,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(color: ink),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              brandName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: ink,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Spacer(),
                            if (frozen) ...[
                              Icon(Icons.ac_unit, size: 16, color: ink),
                              const SizedBox(width: 5),
                              Text(
                                'Frozen',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: ink,
                                ),
                              ),
                            ] else
                              Text(
                                card.kind.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: ink,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomPaint(
                          size: const Size(38, 28),
                          painter: _ChipPainter(ink.withValues(alpha: 0.75)),
                        ),
                        const Spacer(),
                        Text(
                          showDetails ? card.groupedNumber : card.maskedNumber,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFeatures: tabularFigures,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _CardField(
                                label: 'Name',
                                value: card.holder,
                                color: ink,
                              ),
                            ),
                            _CardField(
                              label: 'Expires',
                              value: card.expiry,
                              color: ink,
                            ),
                            const SizedBox(width: 18),
                            _CardField(
                              label: 'CVV',
                              value: showDetails ? card.cvv : '•••',
                              color: ink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.75),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(
            color: color,
            fontFeatures: tabularFigures,
          ),
        ),
      ],
    );
  }
}

/// Rings rising from the corner of the card, replaced by frost-like diagonal
/// hatching while the card is frozen.
class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter({required this.color, required this.frozen});

  final Color color;
  final bool frozen;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    if (frozen) {
      for (double x = -size.height; x < size.width; x += 14) {
        canvas.drawLine(
          Offset(x, size.height),
          Offset(x + size.height, 0),
          paint,
        );
      }
      return;
    }
    final center = Offset(size.width * 1.02, size.height * 1.05);
    final longest = sqrt(size.width * size.width + size.height * size.height);
    for (double radius = 46; radius < longest * 0.72; radius += 26) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.frozen != frozen;
  }
}

class _ChipPainter extends CustomPainter {
  const _ChipPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, paint);
    final third = size.height / 3;
    canvas.drawLine(Offset(0, third), Offset(size.width * 0.34, third), paint);
    canvas.drawLine(
      Offset(0, third * 2),
      Offset(size.width * 0.34, third * 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, third),
      Offset(size.width, third),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, third * 2),
      Offset(size.width, third * 2),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * 0.34, 0, size.width * 0.66, size.height),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ChipPainter oldDelegate) => oldDelegate.color != color;
}
