import 'package:flutter/material.dart';

import '../models/daily_summary.dart';
import '../models/format.dart';
import '../models/sale.dart';
import '../state/pos_scope.dart';
import '../widgets/panel.dart';
import '../widgets/pos_theme.dart';
import '../widgets/sales_charts.dart';
import 'receipt_screen.dart';

/// End-of-day view of takings, one day at a time.
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  DateTime _day = startOfDay(DateTime.now());

  void _shift(int days) =>
      setState(() => _day = DateTime(_day.year, _day.month, _day.day + days));

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final summary = store.summaryFor(_day);
    final isToday = isSameDay(_day, DateTime.now());

    final stats = StatGrid(
      minWidth: 150,
      children: [
        StatTile(
          label: 'Takings',
          value: formatMoney(summary.takingsCents),
          caption: 'Including tax',
        ),
        StatTile(
          label: 'Net sales',
          value: formatMoney(summary.netSalesCents),
          caption: '${formatMoney(summary.discountCents)} discounts',
        ),
        StatTile(
          label: 'Transactions',
          value: '${summary.saleCount}',
          caption: '${summary.unitsSold} units',
        ),
        StatTile(
          label: 'Average sale',
          value: formatMoney(summary.averageSaleCents),
          caption: '${formatMoney(summary.taxCents)} tax collected',
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final hourly = Panel(
          title: 'Takings by hour',
          child: HourlyBars(hourlyCents: summary.hourlyCents),
        );
        final split = Panel(
          title: 'Payment methods',
          child: PaymentSplit(
            cashCents: summary.cashCents,
            cardCents: summary.cardCents,
          ),
        );
        final drawer = Panel(
          title: 'Cash drawer',
          child: _CashDrawer(
            floatCents: store.profile.openingFloatCents,
            cashCents: summary.cashCents,
          ),
        );
        final top = Panel(
          title: 'Top products',
          child: _TopProducts(products: summary.topProducts),
        );
        final list = Panel(
          title: 'Transactions',
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _SaleList(sales: summary.sales),
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          children: [
            _DayHeader(
              day: _day,
              isToday: isToday,
              onPrevious: () => _shift(-1),
              onNext: isToday ? null : () => _shift(1),
            ),
            const SizedBox(height: 12),
            stats,
            const SizedBox(height: 10),
            if (summary.saleCount == 0)
              const Panel(
                child: EmptyMessage(
                  icon: Icons.bar_chart_rounded,
                  message: 'No sales on this day.',
                ),
              )
            else if (wide) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [hourly, const SizedBox(height: 10), list],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        split,
                        const SizedBox(height: 10),
                        drawer,
                        const SizedBox(height: 10),
                        top,
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              hourly,
              const SizedBox(height: 10),
              split,
              const SizedBox(height: 10),
              drawer,
              const SizedBox(height: 10),
              top,
              const SizedBox(height: 10),
              list,
            ],
          ],
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime day;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? 'Today' : formatDate(day),
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                isToday ? formatDate(day) : 'Daily summary',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Previous day',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: onPrevious,
        ),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          tooltip: 'Next day',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _CashDrawer extends StatelessWidget {
  const _CashDrawer({required this.floatCents, required this.cashCents});

  final int floatCents;
  final int cashCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget row(String label, int cents, {bool strong = false}) {
      final style = strong
          ? theme.textTheme.titleSmall
          : theme.textTheme.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(formatMoney(cents), style: style?.tabular),
          ],
        ),
      );
    }

    return Column(
      children: [
        row('Opening float', floatCents),
        row('Cash sales', cashCents),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(),
        ),
        row('Expected in drawer', floatCents + cashCents, strong: true),
      ],
    );
  }
}

class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.products});

  final List<TopProduct> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final best = products.isEmpty ? 1 : products.first.netCents;

    return Column(
      children: [
        for (final product in products)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.units} sold',
                      style: theme.textTheme.bodySmall!.tabular.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatMoney(product.netCents),
                      style: theme.textTheme.bodyMedium!.tabular.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FractionallySizedBox(
                  widthFactor: best == 0 ? 0 : product.netCents / best,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SaleList extends StatelessWidget {
  const _SaleList({required this.sales});

  final List<Sale> sales;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      children: [
        for (final sale in sales)
          InkWell(
            borderRadius: BorderRadius.circular(PosTheme.tileRadius),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReceiptScreen(sale: sale, reprint: true),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    sale.payment is CashPayment
                        ? Icons.payments_outlined
                        : Icons.credit_card_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.receiptNumber,
                          style: theme.textTheme.bodyMedium!.tabular,
                        ),
                        Text(
                          '${formatTime(sale.createdAt)}, '
                          '${sale.itemCount} item'
                          '${sale.itemCount == 1 ? '' : 's'}, '
                          '${sale.payment.label}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatMoney(sale.totals.totalCents),
                    style: theme.textTheme.titleSmall!.tabular,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
