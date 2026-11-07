enum TransactionCategory {
  groceries('Groceries'),
  dining('Dining'),
  transport('Transport'),
  shopping('Shopping'),
  bills('Bills'),
  housing('Housing'),
  entertainment('Entertainment'),
  health('Health'),
  transfer('Transfers'),
  income('Income');

  const TransactionCategory(this.label);

  final String label;
}

enum TransactionStatus {
  pending('Pending'),
  completed('Completed');

  const TransactionStatus(this.label);

  final String label;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.title,
    required this.category,
    required this.amountCents,
    required this.date,
    required this.reference,
    this.status = TransactionStatus.completed,
    this.note,
    this.cardId,
    this.payeeId,
    this.counterAccountId,
  });

  final String id;
  final String accountId;
  final String title;
  final TransactionCategory category;

  /// Negative for money leaving the account, positive for money coming in.
  final int amountCents;
  final DateTime date;
  final String reference;
  final TransactionStatus status;
  final String? note;

  /// The card used, for card purchases.
  final String? cardId;

  /// The payee, for payments to or from a saved recipient.
  final String? payeeId;

  /// The customer's other account, for moves between their own accounts.
  final String? counterAccountId;

  bool get isCredit => amountCents > 0;

  bool get isPending => status == TransactionStatus.pending;

  bool get isInternal => counterAccountId != null;

  /// Moves between own accounts and incoming money don't count as spending.
  bool get isSpending => amountCents < 0 && !isInternal;
}
