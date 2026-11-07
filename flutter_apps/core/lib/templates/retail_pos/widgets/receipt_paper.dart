import 'package:flutter/material.dart';

import '../models/format.dart';
import '../models/sale.dart';
import '../models/store_profile.dart';
import 'code39_barcode.dart';
import 'leader_row.dart';
import 'pos_theme.dart';
import 'torn_paper.dart';

class ReceiptPaper extends StatelessWidget {
  const ReceiptPaper({super.key, required this.sale, required this.store});

  final Sale sale;
  final StoreProfile store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final body = theme.textTheme.bodyMedium;
    final totals = sale.totals;
    final payment = sale.payment;

    return TornPaper(
      tornTop: true,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              store.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            for (final line in store.addressLines)
              Text(line, textAlign: TextAlign.center, style: muted),
            Text(store.phone, textAlign: TextAlign.center, style: muted),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Text(sale.receiptNumber, style: muted)),
                Text(store.tillName, style: muted),
              ],
            ),
            Text(formatDateTime(sale.createdAt), style: muted),
            const _Rule(),
            for (final line in sale.lines) ...[
              LeaderRow(
                label: line.name,
                value: formatMoney(line.unitPriceCents * line.quantity),
                style: body,
              ),
              if (line.quantity > 1)
                Text(
                  '${line.quantity} x ${formatMoney(line.unitPriceCents)}',
                  style: muted?.tabular,
                ),
              if (line.discountCents > 0)
                LeaderRow(
                  label: line.discountLabel ?? 'Discount',
                  value: formatMoney(-line.discountCents),
                  style: muted,
                ),
              const SizedBox(height: 4),
            ],
            const _Rule(),
            LeaderRow(
              label: 'Subtotal',
              value: formatMoney(totals.grossCents),
              style: body,
            ),
            if (totals.orderDiscountCents > 0)
              LeaderRow(
                label: 'Order ${sale.orderDiscountLabel ?? 'discount'}',
                value: formatMoney(-totals.orderDiscountCents),
                style: body,
              ),
            LeaderRow(
              label:
                  '${store.taxLabel} '
                  '${formatBasisPoints(store.taxRateBasisPoints)}',
              value: formatMoney(totals.taxCents),
              style: body,
            ),
            const SizedBox(height: 6),
            LeaderRow(
              label: 'Total',
              value: formatMoney(totals.totalCents),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ...switch (payment) {
              CashPayment(:final tenderedCents, :final changeCents) => [
                LeaderRow(
                  label: 'Cash',
                  value: formatMoney(tenderedCents),
                  style: body,
                ),
                LeaderRow(
                  label: 'Change',
                  value: formatMoney(changeCents),
                  style: body,
                ),
              ],
              CardPayment(:final brand, :final last4, :final authCode) => [
                LeaderRow(
                  label: '$brand ending $last4',
                  value: formatMoney(totals.totalCents),
                  style: body,
                ),
                LeaderRow(label: 'Auth code', value: authCode, style: muted),
              ],
            },
            const SizedBox(height: 18),
            Code39Barcode(data: sale.receiptNumber),
            const SizedBox(height: 6),
            Text(
              sale.receiptNumber,
              textAlign: TextAlign.center,
              style: muted?.tabular.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text('Thank you', textAlign: TextAlign.center, style: muted),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(),
  );
}

/// Reveals its child top to bottom, like paper leaving a printer. Call
/// [PaperFeedState.replay] through a [GlobalKey] to run it again.
class PaperFeed extends StatefulWidget {
  const PaperFeed({super.key, required this.child});

  final Widget child;

  @override
  State<PaperFeed> createState() => PaperFeedState();
}

class PaperFeedState extends State<PaperFeed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) replay();
  }

  void replay() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return ClipRect(
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Align(
          alignment: Alignment.topCenter,
          heightFactor: curved.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
