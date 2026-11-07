enum AccountKind {
  checking('Checking'),
  savings('Savings'),
  pot('Savings pot');

  const AccountKind(this.label);

  final String label;
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.kind,
    required this.lastFour,
    required this.balanceCents,
  });

  final String id;
  final String name;
  final AccountKind kind;
  final String lastFour;
  final int balanceCents;

  String get mask => '•• $lastFour';

  Account copyWith({int? balanceCents}) {
    return Account(
      id: id,
      name: name,
      kind: kind,
      lastFour: lastFour,
      balanceCents: balanceCents ?? this.balanceCents,
    );
  }
}
