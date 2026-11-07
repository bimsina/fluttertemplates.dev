import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/formatting.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../state/wallet_scope.dart';
import 'category_style.dart';
import 'empty_state.dart';
import 'transaction_tile.dart';

/// Search, filters and a date-grouped list of transactions.
///
/// [scope] limits what the browser can ever show, such as a single account.
/// The customer's own filters apply on top of it.
class TransactionBrowser extends StatefulWidget {
  const TransactionBrowser({
    super.key,
    required this.onOpen,
    this.scope,
    this.showAccountFilter = true,
    this.selectedId,
    this.emptyTitle = 'No transactions yet',
    this.emptyMessage = 'Payments and transfers will show up here.',
  });

  final ValueChanged<Transaction> onOpen;
  final bool Function(Transaction transaction)? scope;
  final bool showAccountFilter;
  final String? selectedId;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<TransactionBrowser> createState() => _TransactionBrowserState();
}

class _TransactionBrowserState extends State<TransactionBrowser> {
  final TextEditingController _search = TextEditingController();
  TransactionFilter _filter = const TransactionFilter();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _search.clear();
    setState(() => _filter = const TransactionFilter());
  }

  Future<void> _openFilterSheet() async {
    final accounts = WalletScope.read(context).accounts;
    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _FilterSheet(
        filter: _filter,
        accounts: widget.showAccountFilter ? accounts : const [],
      ),
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final all = WalletScope.of(context).transactions;
    final scoped = widget.scope == null
        ? all
        : all.where(widget.scope!).toList();
    final now = DateTime.now();
    final visible = scoped.where((t) => _filter.matches(t, now)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) =>
                      setState(() => _filter = _filter.copyWith(query: value)),
                  decoration: InputDecoration(
                    hintText: 'Search transactions',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(
                                () => _filter = _filter.copyWith(query: ''),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: _filter.sheetFilterCount > 0,
                label: Text('${_filter.sheetFilterCount}'),
                child: IconButton.filledTonal(
                  tooltip: 'Filters',
                  style: IconButton.styleFrom(
                    fixedSize: const Size(50, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.tune),
                  onPressed: _openFilterSheet,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final flow in TransactionFlow.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(flow.label),
                    selected: _filter.flow == flow,
                    onSelected: (_) =>
                        setState(() => _filter = _filter.copyWith(flow: flow)),
                  ),
                ),
              FilterChip(
                label: const Text('Pending'),
                selected: _filter.pendingOnly,
                onSelected: (selected) => setState(
                  () => _filter = _filter.copyWith(pendingOnly: selected),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: visible.isEmpty
              ? _buildEmpty(scoped.isEmpty)
              : _TransactionList(
                  transactions: visible,
                  now: now,
                  selectedId: widget.selectedId,
                  onOpen: widget.onOpen,
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty(bool nothingAtAll) {
    if (nothingAtAll) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: widget.emptyTitle,
        message: widget.emptyMessage,
      );
    }
    return EmptyState(
      icon: Icons.search_off,
      title: 'Nothing matches',
      message: 'Try a different search, or clear your filters.',
      actionLabel: 'Clear filters',
      onAction: _clearFilters,
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.now,
    required this.selectedId,
    required this.onOpen,
  });

  final List<Transaction> transactions;
  final DateTime now;
  final String? selectedId;
  final ValueChanged<Transaction> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A flat list of day labels and transactions, so ListView stays lazy.
    final rows = <Object>[];
    String? lastDay;
    for (final transaction in transactions) {
      final day = formatDayLabel(transaction.date, now);
      if (day != lastDay) {
        rows.add(day);
        lastDay = day;
      }
      rows.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is Transaction) {
          return TransactionTile(
            key: ValueKey(row.id),
            transaction: row,
            selected: row.id == selectedId,
            onTap: () => onOpen(row),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
          child: Text(
            row as String,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.filter, required this.accounts});

  final TransactionFilter filter;

  /// Empty when the list is already limited to one account.
  final List<Account> accounts;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late FilterPeriod _period = widget.filter.period;
  late Set<TransactionCategory> _categories = {...widget.filter.categories};
  late String? _accountId = widget.filter.accountId;

  void _toggleCategory(TransactionCategory category) {
    setState(() {
      _categories = {..._categories};
      if (!_categories.remove(category)) _categories.add(category);
    });
  }

  void _reset() {
    setState(() {
      _period = FilterPeriod.allTime;
      _categories = {};
      _accountId = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      widget.filter.copyWith(
        period: _period,
        categories: _categories,
        accountId: _accountId,
        clearAccount: _accountId == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Filters', style: theme.textTheme.titleLarge),
                ),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SheetLabel('Period'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final period in FilterPeriod.values)
                          ChoiceChip(
                            label: Text(period.label),
                            selected: _period == period,
                            onSelected: (_) => setState(() => _period = period),
                          ),
                      ],
                    ),
                    if (widget.accounts.isNotEmpty) ...[
                      const _SheetLabel('Account'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ChoiceChip(
                            label: const Text('All accounts'),
                            selected: _accountId == null,
                            onSelected: (_) =>
                                setState(() => _accountId = null),
                          ),
                          for (final account in widget.accounts)
                            ChoiceChip(
                              label: Text(account.name),
                              selected: _accountId == account.id,
                              onSelected: (_) =>
                                  setState(() => _accountId = account.id),
                            ),
                        ],
                      ),
                    ],
                    const _SheetLabel('Category'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final category in TransactionCategory.values)
                          FilterChip(
                            avatar: Icon(category.icon, size: 18),
                            label: Text(category.label),
                            selected: _categories.contains(category),
                            onSelected: (_) => _toggleCategory(category),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            FilledButton(onPressed: _apply, child: const Text('Show results')),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
