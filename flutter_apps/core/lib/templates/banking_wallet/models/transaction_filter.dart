import 'formatting.dart';
import 'transaction.dart';

enum TransactionFlow {
  all('All'),
  moneyIn('Money in'),
  moneyOut('Money out');

  const TransactionFlow(this.label);

  final String label;
}

enum FilterPeriod {
  allTime('All time', null),
  week('7 days', 7),
  month('30 days', 30),
  quarter('90 days', 90);

  const FilterPeriod(this.label, this.days);

  final String label;
  final int? days;
}

/// What the customer has asked to see on a transaction list.
class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.flow = TransactionFlow.all,
    this.pendingOnly = false,
    this.period = FilterPeriod.allTime,
    this.categories = const {},
    this.accountId,
  });

  final String query;
  final TransactionFlow flow;
  final bool pendingOnly;
  final FilterPeriod period;
  final Set<TransactionCategory> categories;
  final String? accountId;

  /// How many filters live in the sheet, for the badge on the filter button.
  int get sheetFilterCount =>
      (period == FilterPeriod.allTime ? 0 : 1) +
      categories.length +
      (accountId == null ? 0 : 1);

  bool get isActive =>
      query.trim().isNotEmpty ||
      flow != TransactionFlow.all ||
      pendingOnly ||
      sheetFilterCount > 0;

  TransactionFilter copyWith({
    String? query,
    TransactionFlow? flow,
    bool? pendingOnly,
    FilterPeriod? period,
    Set<TransactionCategory>? categories,
    String? accountId,
    bool clearAccount = false,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      flow: flow ?? this.flow,
      pendingOnly: pendingOnly ?? this.pendingOnly,
      period: period ?? this.period,
      categories: categories ?? this.categories,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
    );
  }

  bool matches(Transaction transaction, DateTime now) {
    if (flow == TransactionFlow.moneyIn && !transaction.isCredit) return false;
    if (flow == TransactionFlow.moneyOut && transaction.isCredit) return false;
    if (pendingOnly && !transaction.isPending) return false;
    if (accountId != null && transaction.accountId != accountId) return false;
    if (categories.isNotEmpty && !categories.contains(transaction.category)) {
      return false;
    }
    final days = period.days;
    if (days != null &&
        transaction.date.isBefore(now.subtract(Duration(days: days)))) {
      return false;
    }
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final haystack = [
      transaction.title,
      transaction.category.label,
      transaction.note ?? '',
      formatCents(transaction.amountCents.abs()),
    ].join(' ').toLowerCase();
    return haystack.contains(needle);
  }
}
