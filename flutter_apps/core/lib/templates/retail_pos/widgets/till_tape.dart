import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/format.dart';
import '../screens/payment_screen.dart';
import '../state/pos_scope.dart';
import 'discount_dialog.dart';
import 'leader_row.dart';
import 'pos_theme.dart';
import 'quantity_stepper.dart';
import 'torn_paper.dart';

/// The open sale, drawn as the tape coming out of a till. Shared by the side
/// panel on tablets and the sheet on phones.
class TillTape extends StatelessWidget {
  const TillTape({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final cart = store.cart;
    final totals = store.totals;
    final issues = store.stockIssues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TornPaper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TapeHeader(itemCount: cart.itemCount),
                Expanded(
                  child: cart.isEmpty
                      ? const _EmptyTape()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: cart.lines.length,
                          itemBuilder: (context, index) {
                            final line = cart.lines[index];
                            return _TapeLine(
                              key: ValueKey(line.product.id),
                              line: line,
                            );
                          },
                        ),
                ),
                if (!cart.isEmpty) _TapeTotals(cart: cart, totals: totals),
              ],
            ),
          ),
        ),
        if (issues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Reduce ${issues.first.product.name} to '
              '${issues.first.product.stock} to continue',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: store.canCheckout
                ? () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PaymentScreen(),
                    ),
                  )
                : null,
            child: Text(
              cart.isEmpty
                  ? 'Charge'
                  : 'Charge ${formatMoney(totals.totalCents)}',
              style: Theme.of(context).textTheme.titleMedium!.tabular.copyWith(
                color: store.canCheckout
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TapeHeader extends StatelessWidget {
  const _TapeHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PosScope.read(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 6, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current sale', style: theme.textTheme.titleMedium),
                Text(
                  itemCount == 0
                      ? store.profile.tillName
                      : '${store.profile.tillName}, '
                            '$itemCount item${itemCount == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (itemCount > 0)
            TextButton(onPressed: store.clearCart, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _EmptyTape extends StatelessWidget {
  const _EmptyTape();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 36, color: muted),
            const SizedBox(height: 10),
            Text(
              'Tap a product or scan a barcode to start the sale.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapeLine extends StatelessWidget {
  const _TapeLine({super.key, required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = PosScope.read(context);
    final product = line.product;
    final overStock = line.quantity > product.stock;

    return Dismissible(
      key: ValueKey('dismiss-${product.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => store.removeLine(product),
      background: ColoredBox(
        color: scheme.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_outline_rounded,
              color: scheme.onErrorContainer,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LeaderRow(
              label: product.name,
              value: formatMoney(line.netCents),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                QuantityStepper(
                  value: line.quantity,
                  max: product.stock,
                  label: '${product.name} quantity',
                  onChanged: (value) => store.setQuantity(product, value),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    overStock
                        ? 'Only ${product.stock} in stock'
                        : '${formatMoney(product.priceCents)} each',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.tabular.copyWith(
                      color: overStock ? scheme.error : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: line.discount.isNone
                        ? scheme.onSurfaceVariant
                        : scheme.primary,
                  ),
                  onPressed: () async {
                    final discount = await showDiscountDialog(
                      context,
                      title: 'Discount ${product.name}',
                      baseCents: line.grossCents,
                      current: line.discount,
                    );
                    if (discount != null) {
                      store.setLineDiscount(product, discount);
                    }
                  },
                  child: Text(
                    line.discount.isNone ? 'Discount' : line.discount.label,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TapeTotals extends StatelessWidget {
  const _TapeTotals({required this.cart, required this.totals});

  final Cart cart;
  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = PosScope.read(context);
    final small = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final afterLineDiscounts = totals.grossCents - totals.lineDiscountCents;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LeaderRow(
            label: 'Subtotal',
            value: formatMoney(totals.grossCents),
            style: small,
          ),
          if (totals.lineDiscountCents > 0)
            LeaderRow(
              label: 'Item discounts',
              value: formatMoney(-totals.lineDiscountCents),
              style: small,
            ),
          InkWell(
            onTap: () async {
              final discount = await showDiscountDialog(
                context,
                title: 'Discount whole sale',
                baseCents: afterLineDiscounts,
                current: cart.discount,
              );
              if (discount != null) store.setOrderDiscount(discount);
            },
            child: cart.discount.isNone
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      'Add order discount',
                      style: small?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : LeaderRow(
                    label: 'Order ${cart.discount.label}',
                    value: formatMoney(-totals.orderDiscountCents),
                    style: small?.copyWith(color: theme.colorScheme.primary),
                  ),
          ),
          LeaderRow(
            label:
                '${store.profile.taxLabel} '
                '${formatBasisPoints(store.profile.taxRateBasisPoints)}',
            value: formatMoney(totals.taxCents),
            style: small,
          ),
          const SizedBox(height: 6),
          LeaderRow(
            label: 'Total',
            value: formatMoney(totals.totalCents),
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

/// The phone-size summary of the tape. Tapping it opens the full tape.
class TapeBar extends StatelessWidget {
  const TapeBar({super.key});

  Future<void> _open(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PosTheme.ground(Theme.of(context).colorScheme),
      showDragHandle: true,
      builder: (context) => SizedBox(
        height: height * 0.86,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: TillTape(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = PosScope.of(context);
    final count = store.cart.itemCount;

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: count == 0
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Material(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _open(context),
                  child: SizedBox(
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            height: 28,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: scheme.onPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$count',
                              style: theme.textTheme.labelLarge!.tabular
                                  .copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Review sale',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                          Text(
                            formatMoney(store.totals.totalCents),
                            style: theme.textTheme.titleMedium!.tabular
                                .copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
