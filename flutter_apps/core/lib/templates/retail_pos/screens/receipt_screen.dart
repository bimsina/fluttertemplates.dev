import 'package:flutter/material.dart';

import '../models/format.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../state/pos_scope.dart';
import '../widgets/pos_theme.dart';
import '../widgets/receipt_paper.dart';
import '../widgets/stale_data_notice.dart';

/// Shown after a sale, and when reopening one from the sales list.
class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({
    super.key,
    required this.sale,
    this.lowStock = const [],
    this.reprint = false,
  });

  final Sale sale;

  /// Products from this sale that are now low, shown beside the receipt.
  final List<Product> lowStock;

  /// True when opened from history rather than straight after a sale.
  final bool reprint;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final _feedKey = GlobalKey<PaperFeedState>();
  bool _printing = false;

  Future<void> _print() async {
    final store = PosScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _printing = true);
    _feedKey.currentState?.replay();
    // The sale is done either way, so a printer fault only costs the printout.
    String message;
    try {
      final result = await store.receiptPrinter.printReceipt(
        widget.sale,
        store.profile,
      );
      message = result.message;
    } catch (error, stackTrace) {
      debugPrint('Receipt failed to print: $error\n$stackTrace');
      message = 'Could not print the receipt. Try again.';
    }
    if (!mounted) return;
    setState(() => _printing = false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.read(context);
    final receipt = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: PaperFeed(
        key: _feedKey,
        child: Padding(
          // Room for the paper shadow inside the feed clip.
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 10),
          child: ReceiptPaper(sale: widget.sale, store: store.profile),
        ),
      ),
    );
    final outcome = _SaleOutcome(
      sale: widget.sale,
      lowStock: widget.lowStock,
      reprint: widget.reprint,
      printing: _printing,
      onPrint: _print,
    );

    return PopScope(
      canPop: widget.reprint,
      child: Scaffold(
        appBar: widget.reprint
            ? AppBar(title: Text('Receipt ${widget.sale.receiptNumber}'))
            : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 760) {
                return Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: outcome,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: receipt,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    outcome,
                    const SizedBox(height: 20),
                    Center(child: receipt),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SaleOutcome extends StatelessWidget {
  const _SaleOutcome({
    required this.sale,
    required this.lowStock,
    required this.reprint,
    required this.printing,
    required this.onPrint,
  });

  final Sale sale;
  final List<Product> lowStock;
  final bool reprint;
  final bool printing;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final payment = sale.payment;
    final (label, value) = switch (payment) {
      CashPayment(:final changeCents) when changeCents > 0 => (
        'Change due',
        formatMoney(changeCents),
      ),
      CashPayment() => (
        'Paid in cash, no change',
        formatMoney(sale.totals.totalCents),
      ),
      CardPayment(:final brand, :final last4) => (
        'Paid by $brand ending $last4',
        formatMoney(sale.totals.totalCents),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!reprint) ...[
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sale complete',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const StaleDataNotice(bottomGap: 14),
        ],
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: theme.textTheme.displaySmall!.tabular.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        ),
        if (lowStock.isNotEmpty) ...[
          const SizedBox(height: 16),
          _LowStockNotice(products: lowStock),
        ],
        const SizedBox(height: 20),
        if (!reprint) ...[
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('New sale'),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          icon: const Icon(Icons.print_outlined),
          label: Text(reprint ? 'Reprint receipt' : 'Print receipt'),
          onPressed: printing ? null : onPrint,
        ),
      ],
    );
  }
}

class _LowStockNotice extends StatelessWidget {
  const _LowStockNotice({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onTertiaryContainer,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(PosTheme.tileRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: scheme.onTertiaryContainer,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Low stock after this sale',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final product in products)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    ),
                  ),
                  Text(
                    product.level == StockLevel.out
                        ? 'Sold out'
                        : '${product.stock} left',
                    style: style?.tabular,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
