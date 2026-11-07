import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../state/spending_insights.dart';
import '../state/wallet_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/money_text.dart';
import '../widgets/spending_charts.dart';
import '../widgets/tab_header.dart';
import '../widgets/wallet_theme.dart';
import 'activity_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  /// Null follows the current month, which is always the last bar.
  int? _selectedIndex;

  void _openCategory(
    BuildContext context,
    MonthlySpending month,
    CategorySpending item,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionsScreen(
          title: '${item.category.label}, ${monthLong(month.month)}',
          scope: (transaction) =>
              transaction.isSpending &&
              transaction.category == item.category &&
              isInMonth(transaction, month.month),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);
    final months = monthlySpending(wallet.transactions, now: DateTime.now());
    final selected = _selectedIndex ?? months.length - 1;
    final month = months[selected];
    final previous = selected > 0 ? months[selected - 1] : null;
    final hasAnySpending = months.any((m) => m.totalCents > 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= twoColumnBreakpoint;
        final chart = _ChartPanel(
          months: months,
          selectedIndex: selected,
          previous: previous,
          onSelected: (index) => setState(() => _selectedIndex = index),
        );
        final breakdown = _Breakdown(
          month: month,
          onOpen: (item) => _openCategory(context, month, item),
        );

        if (!hasAnySpending) {
          return const Column(
            children: [
              TabHeader(title: 'Insights'),
              Expanded(
                child: EmptyState(
                  icon: Icons.bar_chart,
                  title: 'Nothing to chart yet',
                  message:
                      'Your spending will show up here once you pay '
                      'for something.',
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: twoColumns ? 1040 : 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TabHeader(title: 'Insights'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: twoColumns
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: chart),
                              const SizedBox(width: 24),
                              Expanded(child: breakdown),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              chart,
                              const SizedBox(height: 18),
                              breakdown,
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({
    required this.months,
    required this.selectedIndex,
    required this.previous,
    required this.onSelected,
  });

  final List<MonthlySpending> months;
  final int selectedIndex;
  final MonthlySpending? previous;
  final ValueChanged<int> onSelected;

  /// `12% less than September`, or null when there is nothing to compare to.
  String? _comparison(MonthlySpending month) {
    final before = previous;
    if (before == null || before.totalCents == 0) return null;
    final change =
        ((month.totalCents - before.totalCents) * 100 / before.totalCents)
            .round();
    if (change == 0) return 'About the same as ${monthLong(before.month)}';
    final direction = change < 0 ? 'less' : 'more';
    return '${change.abs()}% $direction than ${monthLong(before.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final month = months[selectedIndex];
    final isCurrent = selectedIndex == months.length - 1;
    final comparison = _comparison(month);
    final withSpending = months.where((m) => m.totalCents > 0).toList();
    final average = withSpending.isEmpty
        ? 0
        : withSpending.fold(0, (sum, m) => sum + m.totalCents) ~/
              withSpending.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isCurrent
                ? '${monthLong(month.month)} so far'
                : monthLong(month.month),
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          AnimatedMoneyText(
            month.totalCents,
            style: theme.textTheme.headlineMedium,
          ),
          if (comparison != null)
            Text(
              comparison,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 14),
          MonthlyBarChart(
            months: months,
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dashed line: average',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MoneyText(
                average,
                decimals: false,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.month, required this.onOpen});

  final MonthlySpending month;
  final ValueChanged<CategorySpending> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = month.byCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text('Where it went', style: theme.textTheme.titleMedium),
        ),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.savings_outlined,
            title: 'No spending in ${monthLong(month.month)}',
            message: 'Pick another month on the chart.',
          )
        else
          for (final item in items)
            CategoryBarRow(
              item: item,
              totalCents: month.totalCents,
              largestCents: items.first.cents,
              onTap: () => onOpen(item),
            ),
      ],
    );
  }
}
