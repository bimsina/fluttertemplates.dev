enum CardKind {
  debit('Debit'),
  virtual('Virtual');

  const CardKind(this.label);

  final String label;
}

class BankCard {
  const BankCard({
    required this.id,
    required this.accountId,
    required this.label,
    required this.kind,
    required this.holder,
    required this.number,
    required this.expiry,
    required this.cvv,
    required this.monthlyLimitCents,
    this.isFrozen = false,
  });

  final String id;
  final String accountId;
  final String label;
  final CardKind kind;
  final String holder;

  /// Sixteen digits, no spaces. A real backend would return this only through
  /// a short-lived, PCI-scoped call, never in the card list.
  final String number;
  final String expiry;
  final String cvv;
  final int monthlyLimitCents;
  final bool isFrozen;

  String get lastFour => number.substring(number.length - 4);

  String get maskedNumber => '••••  ••••  ••••  $lastFour';

  String get groupedNumber {
    final groups = [
      for (var i = 0; i < number.length; i += 4) number.substring(i, i + 4),
    ];
    return groups.join('  ');
  }

  BankCard copyWith({bool? isFrozen}) {
    return BankCard(
      id: id,
      accountId: accountId,
      label: label,
      kind: kind,
      holder: holder,
      number: number,
      expiry: expiry,
      cvv: cvv,
      monthlyLimitCents: monthlyLimitCents,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}
