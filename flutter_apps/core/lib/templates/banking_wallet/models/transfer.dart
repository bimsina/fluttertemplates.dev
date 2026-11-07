import 'dart:math';

import 'payee.dart';
import 'transaction.dart';

/// The most a single transfer can move.
const int transferLimitCents = 1000000;

/// A random 128-bit key for one transfer attempt.
String generateIdempotencyKey() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

class TransferRequest {
  const TransferRequest({
    required this.idempotencyKey,
    required this.fromAccountId,
    required this.payee,
    required this.amountCents,
    this.note,
  });

  /// Identifies one attempt to move this money. Retries of the attempt resend
  /// the same key, so the bank applies it at most once.
  final String idempotencyKey;
  final String fromAccountId;
  final Payee payee;
  final int amountCents;
  final String? note;

  bool hasSameDetails(TransferRequest other) {
    return fromAccountId == other.fromAccountId &&
        payee.id == other.payee.id &&
        amountCents == other.amountCents &&
        note == other.note;
  }
}

/// Thrown by the repository when a transfer is rejected. [message] is safe to
/// show to the customer.
class TransferException implements Exception {
  const TransferException(this.message);

  final String message;

  @override
  String toString() => 'TransferException: $message';
}

/// What is known about a transfer once `WalletController.sendMoney` returns.
sealed class TransferOutcome {
  const TransferOutcome();
}

/// The bank moved the money. This stays true even if [isDataFresh] is false,
/// which means the follow-up refresh failed and balances may be out of date.
class TransferCommitted extends TransferOutcome {
  const TransferCommitted(this.transaction, {required this.isDataFresh});

  final Transaction transaction;
  final bool isDataFresh;
}

/// The bank refused the transfer, so no money moved.
class TransferRejected extends TransferOutcome {
  const TransferRejected(this.message);

  final String message;
}

/// No answer came back, for example after a timeout. The money may or may not
/// have moved. Retrying the same request is safe.
class TransferUnknown extends TransferOutcome {
  const TransferUnknown();
}
