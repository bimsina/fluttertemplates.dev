import 'dart:math';

import 'cart.dart';

/// A random 128-bit key for one sale.
String generateSaleKey() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

sealed class Payment {
  const Payment();

  String get label;
}

final class CashPayment extends Payment {
  const CashPayment({required this.tenderedCents, required this.changeCents});

  final int tenderedCents;
  final int changeCents;

  @override
  String get label => 'Cash';
}

final class CardPayment extends Payment {
  const CardPayment({
    required this.brand,
    required this.last4,
    required this.authCode,
  });

  final String brand;
  final String last4;
  final String authCode;

  @override
  String get label => 'Card';
}

/// A line frozen at the moment of sale. Later price edits do not change it.
class SaleLine {
  const SaleLine({
    required this.productId,
    required this.name,
    required this.unitPriceCents,
    required this.quantity,
    required this.discountCents,
    required this.discountLabel,
  });

  factory SaleLine.fromCartLine(CartLine line) => SaleLine(
    productId: line.product.id,
    name: line.product.name,
    unitPriceCents: line.product.priceCents,
    quantity: line.quantity,
    discountCents: line.discountCents,
    discountLabel: line.discount.isNone ? null : line.discount.label,
  );

  final String productId;
  final String name;
  final int unitPriceCents;
  final int quantity;
  final int discountCents;
  final String? discountLabel;

  int get netCents => unitPriceCents * quantity - discountCents;
}

/// What the register sends to the repository. The repository assigns the
/// receipt number and makes the stock change.
class SaleDraft {
  const SaleDraft({
    required this.idempotencyKey,
    required this.lines,
    required this.totals,
    required this.payment,
    this.orderDiscountLabel,
    this.createdAt,
  });

  factory SaleDraft.fromCart(
    Cart cart, {
    required String idempotencyKey,
    required CartTotals totals,
    required Payment payment,
    DateTime? createdAt,
  }) => SaleDraft(
    idempotencyKey: idempotencyKey,
    lines: cart.lines.map(SaleLine.fromCartLine).toList(growable: false),
    totals: totals,
    payment: payment,
    orderDiscountLabel: cart.discount.isNone ? null : cart.discount.label,
    createdAt: createdAt,
  );

  /// Identifies this sale. Every retry resends the same key, so the sale is
  /// recorded at most once.
  final String idempotencyKey;
  final List<SaleLine> lines;
  final CartTotals totals;
  final Payment payment;
  final String? orderDiscountLabel;

  /// Only set when replaying history. Live sales use the repository's clock.
  final DateTime? createdAt;
}

class Sale {
  const Sale({
    required this.receiptNumber,
    required this.createdAt,
    required this.lines,
    required this.totals,
    required this.payment,
    this.orderDiscountLabel,
  });

  /// Digits, `R` and `-` only, so it fits the Code 39 barcode on the receipt.
  final String receiptNumber;
  final DateTime createdAt;
  final List<SaleLine> lines;
  final CartTotals totals;
  final Payment payment;
  final String? orderDiscountLabel;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);
}
