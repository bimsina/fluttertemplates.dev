enum StockMovementReason {
  sale('Sale'),
  received('Delivery received'),
  removed('Damaged or lost'),
  recount('Shelf recount');

  const StockMovementReason(this.label);

  final String label;
}

/// One entry in a product's stock ledger. Stock only changes through these.
class StockMovement {
  const StockMovement({
    required this.productId,
    required this.delta,
    required this.stockAfter,
    required this.reason,
    required this.createdAt,
    this.note,
  });

  final String productId;
  final int delta;
  final int stockAfter;
  final StockMovementReason reason;
  final DateTime createdAt;

  /// Receipt number for sales, free text for manual adjustments.
  final String? note;
}
