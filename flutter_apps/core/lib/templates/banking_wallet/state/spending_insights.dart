import '../models/transaction.dart';

/// One month of spending, split by category.
class MonthlySpending {
  const MonthlySpending({
    required this.month,
    required this.totalCents,
    required this.byCategory,
  });

  /// The first day of the month.
  final DateTime month;
  final int totalCents;

  /// Largest category first. Amounts are positive cents.
  final List<CategorySpending> byCategory;
}

class CategorySpending {
  const CategorySpending(this.category, this.cents);

  final TransactionCategory category;
  final int cents;
}

/// Totals spending for the last [months] months, oldest first. The last entry
/// is the month containing [now].
List<MonthlySpending> monthlySpending(
  List<Transaction> transactions, {
  required DateTime now,
  int months = 6,
}) {
  return [
    for (var offset = months - 1; offset >= 0; offset--)
      _spendingFor(DateTime(now.year, now.month - offset), transactions),
  ];
}

MonthlySpending _spendingFor(DateTime month, List<Transaction> transactions) {
  final totals = <TransactionCategory, int>{};
  for (final transaction in transactions) {
    if (!transaction.isSpending || !isInMonth(transaction, month)) continue;
    totals.update(
      transaction.category,
      (cents) => cents - transaction.amountCents,
      ifAbsent: () => -transaction.amountCents,
    );
  }
  final byCategory = [
    for (final entry in totals.entries)
      CategorySpending(entry.key, entry.value),
  ]..sort((a, b) => b.cents.compareTo(a.cents));
  return MonthlySpending(
    month: month,
    totalCents: byCategory.fold(0, (sum, item) => sum + item.cents),
    byCategory: byCategory,
  );
}

bool isInMonth(Transaction transaction, DateTime month) {
  return transaction.date.year == month.year &&
      transaction.date.month == month.month;
}

/// Money in and out for the month containing [now], ignoring moves between
/// the customer's own accounts.
({int inCents, int outCents}) monthCashFlow(
  List<Transaction> transactions,
  DateTime now,
) {
  var inCents = 0;
  var outCents = 0;
  for (final transaction in transactions) {
    if (transaction.isInternal || !isInMonth(transaction, now)) continue;
    if (transaction.isCredit) {
      inCents += transaction.amountCents;
    } else {
      outCents -= transaction.amountCents;
    }
  }
  return (inCents: inCents, outCents: outCents);
}

/// How much of [cardId]'s monthly limit has been used.
int cardSpendThisMonth(
  List<Transaction> transactions,
  String cardId,
  DateTime now,
) {
  var cents = 0;
  for (final transaction in transactions) {
    if (transaction.cardId == cardId && isInMonth(transaction, now)) {
      cents -= transaction.amountCents;
    }
  }
  return cents;
}
