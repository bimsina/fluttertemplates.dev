import 'format.dart';
import 'product.dart';

enum DiscountKind { percent, amount }

/// A price reduction on one line or on the whole order.
class Discount {
  const Discount.percent(int basisPoints)
    : kind = DiscountKind.percent,
      value = basisPoints;

  const Discount.amount(int cents) : kind = DiscountKind.amount, value = cents;

  static const none = Discount.amount(0);

  final DiscountKind kind;

  /// Basis points for [DiscountKind.percent], cents for [DiscountKind.amount].
  final int value;

  bool get isNone => value == 0;

  /// The cents taken off [baseCents]. Never more than the base itself.
  int appliedTo(int baseCents) {
    final off = kind == DiscountKind.percent
        ? applyBasisPoints(baseCents, value)
        : value;
    return off > baseCents ? baseCents : off;
  }

  String get label => kind == DiscountKind.percent
      ? '${formatBasisPoints(value)} off'
      : '${formatMoney(value)} off';
}

class CartLine {
  const CartLine({
    required this.product,
    required this.quantity,
    this.discount = Discount.none,
  });

  final Product product;
  final int quantity;
  final Discount discount;

  int get grossCents => product.priceCents * quantity;
  int get discountCents => discount.appliedTo(grossCents);
  int get netCents => grossCents - discountCents;

  CartLine copyWith({Product? product, int? quantity, Discount? discount}) =>
      CartLine(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        discount: discount ?? this.discount,
      );
}

class CartTotals {
  const CartTotals({
    required this.grossCents,
    required this.lineDiscountCents,
    required this.orderDiscountCents,
    required this.taxCents,
  });

  /// Shelf price of everything in the cart.
  final int grossCents;
  final int lineDiscountCents;
  final int orderDiscountCents;
  final int taxCents;

  int get discountCents => lineDiscountCents + orderDiscountCents;
  int get totalCents => grossCents - discountCents + taxCents;
}

/// Immutable cart. All pricing rules live here so they can be unit tested
/// without any UI, and so the seed data prices history the same way.
class Cart {
  const Cart({this.lines = const [], this.discount = Discount.none});

  final List<CartLine> lines;

  /// Discount on the whole order, applied after line discounts.
  final Discount discount;

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  int quantityOf(String productId) {
    for (final line in lines) {
      if (line.product.id == productId) return line.quantity;
    }
    return 0;
  }

  CartTotals totals(int taxRateBasisPoints) {
    var gross = 0;
    var lineDiscount = 0;
    var net = 0;
    var taxableNet = 0;
    for (final line in lines) {
      gross += line.grossCents;
      lineDiscount += line.discountCents;
      net += line.netCents;
      if (line.product.taxable) taxableNet += line.netCents;
    }

    final orderDiscount = discount.appliedTo(net);

    // The order discount reduces taxable and exempt goods proportionally.
    final taxableShare = net == 0
        ? 0
        : (orderDiscount * taxableNet + net ~/ 2) ~/ net;
    final tax = applyBasisPoints(taxableNet - taxableShare, taxRateBasisPoints);

    return CartTotals(
      grossCents: gross,
      lineDiscountCents: lineDiscount,
      orderDiscountCents: orderDiscount,
      taxCents: tax,
    );
  }

  Cart add(Product product, {int quantity = 1}) {
    final exists = quantityOf(product.id) > 0;
    return _copy(
      lines: exists
          ? [
              for (final line in lines)
                line.product.id == product.id
                    ? line.copyWith(quantity: line.quantity + quantity)
                    : line,
            ]
          : [...lines, CartLine(product: product, quantity: quantity)],
    );
  }

  Cart setQuantity(String productId, int quantity) => _copy(
    lines: [
      for (final line in lines)
        if (line.product.id != productId)
          line
        else if (quantity > 0)
          line.copyWith(quantity: quantity),
    ],
  );

  Cart setLineDiscount(String productId, Discount value) => _copy(
    lines: [
      for (final line in lines)
        line.product.id == productId ? line.copyWith(discount: value) : line,
    ],
  );

  Cart setOrderDiscount(Discount value) => _copy(discount: value);

  /// Swaps in fresh product snapshots after stock changes.
  Cart refreshProducts(Product? Function(String id) lookup) => _copy(
    lines: [
      for (final line in lines)
        line.copyWith(product: lookup(line.product.id) ?? line.product),
    ],
  );

  Cart _copy({List<CartLine>? lines, Discount? discount}) =>
      Cart(lines: lines ?? this.lines, discount: discount ?? this.discount);
}
