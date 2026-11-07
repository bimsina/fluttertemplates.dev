class Payee {
  const Payee({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    this.ownAccountId,
  });

  final String id;
  final String name;
  final String bankName;
  final String accountNumber;

  /// Set when this payee is one of the customer's own accounts, which makes
  /// the transfer an internal move instead of an outgoing payment.
  final String? ownAccountId;

  bool get isOwnAccount => ownAccountId != null;

  String get mask {
    final digits = accountNumber;
    final tail = digits.length > 4
        ? digits.substring(digits.length - 4)
        : digits;
    return '•• $tail';
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first.isEmpty ? '?' : parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}

/// One attempt to save a payee. Retries resend the same key, so the bank saves
/// it at most once.
class AddPayeeRequest {
  const AddPayeeRequest({
    required this.idempotencyKey,
    required this.name,
    required this.bankName,
    required this.accountNumber,
  });

  final String idempotencyKey;
  final String name;
  final String bankName;
  final String accountNumber;
}

/// Thrown by the repository when a payee is refused, so nothing was saved.
/// [message] is safe to show to the customer.
class PayeeException implements Exception {
  const PayeeException(this.message);

  final String message;

  @override
  String toString() => 'PayeeException: $message';
}

/// What is known about a new payee once `WalletController.addPayee` returns.
sealed class AddPayeeOutcome {
  const AddPayeeOutcome();
}

/// The bank has the payee. This stays true even if [isDataFresh] is false,
/// which means the follow-up refresh failed.
class PayeeSaved extends AddPayeeOutcome {
  const PayeeSaved(this.payee, {required this.isDataFresh});

  final Payee payee;
  final bool isDataFresh;
}

/// The bank refused the payee, so nothing was saved.
class PayeeRejected extends AddPayeeOutcome {
  const PayeeRejected(this.message);

  final String message;
}

/// No answer came back and the payee list couldn't settle it. The payee may or
/// may not be saved. Adding the same details again is safe.
class PayeeUnknown extends AddPayeeOutcome {
  const PayeeUnknown();
}
