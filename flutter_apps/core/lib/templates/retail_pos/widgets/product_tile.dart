import 'package:flutter/material.dart';

import '../models/format.dart';
import '../models/product.dart';
import 'pos_theme.dart';
import 'stock_indicators.dart';

/// A shelf tag. The monogram and shelf code replace photos, so the grid works
/// with a catalogue straight from a stock file. One tap adds one unit.
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.toneIndex,
    required this.inCart,
    required this.onAdd,
  });

  final Product product;
  final int toneIndex;
  final int inCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final soldOut = product.level == StockLevel.out;
    final (toneBackground, toneForeground) = soldOut
        ? (scheme.surfaceContainerHigh, scheme.onSurfaceVariant)
        : PosTheme.categoryTone(scheme, toneIndex);
    final available = product.stock - inCart;

    return Semantics(
      button: true,
      enabled: !soldOut,
      label:
          '${product.name}, ${formatMoney(product.priceCents)}, '
          '${soldOut ? 'out of stock' : '$available available'}'
          '${inCart > 0 ? ', $inCart in sale' : ''}',
      excludeSemantics: true,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PosTheme.tileRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onAdd,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: toneBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 8,
                          top: 6,
                          child: Text(
                            product.sku,
                            style: theme.textTheme.labelSmall!.tabular.copyWith(
                              color: toneForeground,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 2,
                          child: Text(
                            product.monogram,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: toneForeground,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (inCart > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: _InCartCount(count: inCart),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                  child: Row(
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatMoney(product.priceCents),
                            style: theme.textTheme.labelLarge!.tabular.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: StockBadge(
                            product: product,
                            available: available,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InCartCount extends StatelessWidget {
  const _InCartCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey(count),
        constraints: const BoxConstraints(minWidth: 24),
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: theme.textTheme.labelMedium!.tabular.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
