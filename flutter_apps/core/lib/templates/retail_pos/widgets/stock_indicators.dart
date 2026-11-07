import 'package:flutter/material.dart';

import '../models/product.dart';
import 'pos_theme.dart';

Color stockColor(ColorScheme scheme, StockLevel level) => switch (level) {
  StockLevel.healthy => scheme.primary,
  StockLevel.low => scheme.tertiary,
  StockLevel.out => scheme.error,
};

/// Stock state as icon plus words, so it never relies on colour alone.
class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.product, this.available});

  final Product product;

  /// Overrides the count shown, for stock net of the open cart.
  final int? available;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = product.level;
    final count = available ?? product.stock;
    final color = level == StockLevel.healthy
        ? theme.colorScheme.onSurfaceVariant
        : stockColor(theme.colorScheme, level);
    final style = theme.textTheme.labelSmall!.tabular.copyWith(
      color: color,
      fontWeight: level == StockLevel.healthy
          ? FontWeight.w500
          : FontWeight.w700,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (level != StockLevel.healthy) ...[
          Icon(
            level == StockLevel.out
                ? Icons.block_rounded
                : Icons.warning_amber_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
        ],
        Text(
          level == StockLevel.out ? 'Out' : '$count left',
          style: style,
          maxLines: 1,
        ),
      ],
    );
  }
}

/// Stock against a full shelf (three times the reorder point). The tick marks
/// the reorder point.
class StockMeter extends StatelessWidget {
  const StockMeter({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final capacity = product.reorderPoint * 3;
    final fill = capacity == 0
        ? 1.0
        : (product.stock / capacity).clamp(0.0, 1.0);
    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 2,
              bottom: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 2,
              bottom: 2,
              width: constraints.maxWidth * fill,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: stockColor(scheme, product.level),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: constraints.maxWidth / 3 - 1,
              top: 0,
              bottom: 0,
              width: 2,
              child: ColoredBox(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
