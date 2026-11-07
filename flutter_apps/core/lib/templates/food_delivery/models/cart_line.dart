import 'menu_item.dart';

/// One customized item in the cart. Immutable, so an order can keep its lines
/// after the cart has been cleared.
class CartLine {
  const CartLine({
    required this.id,
    required this.item,
    required this.selected,
    required this.quantity,
    this.note = '',
  });

  final String id;
  final MenuItem item;
  final List<ItemOption> selected;
  final int quantity;
  final String note;

  int get unitPriceCents =>
      item.priceCents +
      selected.fold(0, (sum, option) => sum + option.priceCents);

  int get totalCents => unitPriceCents * quantity;

  String get optionsSummary => selected.map((o) => o.name).join(', ');

  /// Two lines with the same signature are merged in the cart.
  String get signature {
    final ids = selected.map((o) => o.id).toList()..sort();
    return '${item.id}|${ids.join(',')}|${note.trim()}';
  }

  CartLine copyWith({int? quantity}) => CartLine(
    id: id,
    item: item,
    selected: selected,
    quantity: quantity ?? this.quantity,
    note: note,
  );
}
