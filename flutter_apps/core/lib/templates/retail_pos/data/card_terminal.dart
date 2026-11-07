import 'dart:math';

sealed class CardEvent {
  const CardEvent();
}

/// The terminal is showing the amount and waiting for a tap or insert.
final class CardWaiting extends CardEvent {
  const CardWaiting();
}

/// The card was read and the issuer is being contacted.
final class CardAuthorizing extends CardEvent {
  const CardAuthorizing();
}

final class CardApproved extends CardEvent {
  const CardApproved({
    required this.brand,
    required this.last4,
    required this.authCode,
  });

  final String brand;
  final String last4;
  final String authCode;
}

final class CardDeclined extends CardEvent {
  const CardDeclined(this.reason);

  final String reason;
}

/// Replace with your payment provider's SDK (Stripe Terminal, Square, Adyen)
/// and pass it to `RetailPosApp(cardTerminal: ...)`.
abstract interface class CardTerminal {
  /// Emits progress and ends with [CardApproved] or [CardDeclined].
  Stream<CardEvent> charge(int amountCents);

  /// Aborts a charge that has not been approved.
  Future<void> cancel();
}

/// Approves after a short pause. Set [declineNext] to rehearse the failure
/// path, which the payment screen exposes as a switch.
class SimulatedCardTerminal implements CardTerminal {
  SimulatedCardTerminal({this.stepDelay = const Duration(milliseconds: 1100)});

  final Duration stepDelay;
  final _random = Random();
  bool declineNext = false;

  @override
  Stream<CardEvent> charge(int amountCents) async* {
    yield const CardWaiting();
    await Future<void>.delayed(stepDelay);
    yield const CardAuthorizing();
    await Future<void>.delayed(stepDelay);
    if (declineNext) {
      declineNext = false;
      yield const CardDeclined('Declined by issuer. Try another card.');
      return;
    }
    yield CardApproved(
      brand: _random.nextBool() ? 'Visa' : 'Mastercard',
      last4: (1000 + _random.nextInt(9000)).toString(),
      authCode: (100000 + _random.nextInt(900000)).toString(),
    );
  }

  @override
  Future<void> cancel() async {}
}
