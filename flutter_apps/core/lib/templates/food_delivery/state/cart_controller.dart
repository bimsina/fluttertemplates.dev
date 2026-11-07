import 'package:flutter/foundation.dart';

import '../models/cart_line.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/restaurant.dart';

/// The current cart plus the delivery details remembered between orders.
///
/// A cart holds items from one restaurant at a time. Totals are derived on
/// read, so every listener always sees consistent numbers.
class CartController extends ChangeNotifier {
  static const serviceFeeRate = 0.05;
  static const taxRate = 0.08;

  Restaurant? _restaurant;
  List<CartLine> _lines = const [];
  PromoCode? _promo;
  int _tipPercent = 15;
  int _nextLineId = 0;
  DeliveryAddress? _address;

  Restaurant? get restaurant => _restaurant;
  List<CartLine> get lines => _lines;
  PromoCode? get promo => _promo;
  int get tipPercent => _tipPercent;
  DeliveryAddress? get address => _address;

  bool get isEmpty => _lines.isEmpty;
  int get itemCount => _lines.fold(0, (sum, line) => sum + line.quantity);
  int get subtotalCents => _lines.fold(0, (sum, line) => sum + line.totalCents);

  /// How much more the customer must add to reach the restaurant minimum.
  int get shortOfMinimumCents {
    final restaurant = _restaurant;
    if (restaurant == null) return 0;
    final missing = restaurant.minimumOrderCents - subtotalCents;
    return missing > 0 ? missing : 0;
  }

  PriceBreakdown get prices {
    final restaurant = _restaurant;
    if (restaurant == null || isEmpty) return PriceBreakdown.empty;
    final subtotal = subtotalCents;
    final promo = _promo;
    return PriceBreakdown(
      subtotalCents: subtotal,
      deliveryFeeCents: promo?.freeDelivery == true
          ? 0
          : restaurant.deliveryFeeCents,
      serviceFeeCents: (subtotal * serviceFeeRate).round(),
      taxCents: (subtotal * taxRate).round(),
      discountCents: promo == null
          ? 0
          : (subtotal * promo.percentOff / 100).round(),
      tipCents: (subtotal * _tipPercent / 100).round(),
    );
  }

  int quantityOf(String itemId) => _lines
      .where((line) => line.item.id == itemId)
      .fold(0, (sum, line) => sum + line.quantity);

  /// True when adding from [restaurant] would need the cart to be replaced.
  bool conflictsWith(Restaurant restaurant) =>
      !isEmpty && _restaurant?.id != restaurant.id;

  void add({
    required Restaurant restaurant,
    required MenuItem item,
    required List<ItemOption> selected,
    required int quantity,
    String note = '',
  }) {
    assert(!conflictsWith(restaurant), 'Clear the cart first');
    _restaurant = restaurant;
    _lines = _merged(
      _lines,
      CartLine(
        id: 'line-${_nextLineId++}',
        item: item,
        selected: selected,
        quantity: quantity,
        note: note.trim(),
      ),
    );
    notifyListeners();
  }

  /// Replaces a line after it was edited on the item screen.
  void replaceLine({
    required String lineId,
    required List<ItemOption> selected,
    required int quantity,
    String note = '',
  }) {
    final index = _lines.indexWhere((line) => line.id == lineId);
    if (index < 0) return;
    final edited = CartLine(
      id: lineId,
      item: _lines[index].item,
      selected: selected,
      quantity: quantity,
      note: note.trim(),
    );
    final others = [..._lines]..removeAt(index);
    final hasTwin = others.any((line) => line.signature == edited.signature);
    _lines = hasTwin
        ? _merged(others, edited)
        : ([..._lines]..[index] = edited);
    notifyListeners();
  }

  void setQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      remove(lineId);
      return;
    }
    _lines = [
      for (final line in _lines)
        line.id == lineId ? line.copyWith(quantity: quantity) : line,
    ];
    notifyListeners();
  }

  void remove(String lineId) {
    _lines = _lines.where((line) => line.id != lineId).toList();
    if (_lines.isEmpty) _resetOrder();
    notifyListeners();
  }

  /// Puts a removed line back, used by the undo action.
  void restore(Restaurant restaurant, CartLine line, int index) {
    if (conflictsWith(restaurant)) return;
    _restaurant = restaurant;
    _lines = [..._lines]..insert(index.clamp(0, _lines.length), line);
    notifyListeners();
  }

  /// Loads the lines of an old order, replacing whatever is in the cart.
  void reorder(Order order) {
    _resetOrder();
    _restaurant = order.restaurant;
    _lines = [
      for (final line in order.lines)
        CartLine(
          id: 'line-${_nextLineId++}',
          item: line.item,
          selected: line.selected,
          quantity: line.quantity,
          note: line.note,
        ),
    ];
    notifyListeners();
  }

  void applyPromo(PromoCode promo) {
    _promo = promo;
    notifyListeners();
  }

  void removePromo() {
    _promo = null;
    notifyListeners();
  }

  void setTipPercent(int percent) {
    _tipPercent = percent;
    notifyListeners();
  }

  void saveAddress(DeliveryAddress address) {
    _address = address;
    notifyListeners();
  }

  void clear() {
    _resetOrder();
    notifyListeners();
  }

  void _resetOrder() {
    _restaurant = null;
    _lines = const [];
    _promo = null;
    _tipPercent = 15;
  }

  List<CartLine> _merged(List<CartLine> lines, CartLine incoming) {
    final index = lines.indexWhere((l) => l.signature == incoming.signature);
    if (index < 0) return [...lines, incoming];
    final existing = lines[index];
    return [...lines]
      ..[index] = existing.copyWith(
        quantity: existing.quantity + incoming.quantity,
      );
  }
}
