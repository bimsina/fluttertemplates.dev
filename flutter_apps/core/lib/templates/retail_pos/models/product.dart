class ProductCategory {
  const ProductCategory({required this.id, required this.name});

  final String id;
  final String name;
}

enum StockLevel { healthy, low, out }

class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.name,
    required this.categoryId,
    required this.priceCents,
    required this.costCents,
    required this.stock,
    required this.reorderPoint,
    this.taxable = true,
  });

  final String id;

  /// Short shelf code printed on the product tile.
  final String sku;

  /// EAN-13 string. This is what a scanner reports.
  final String barcode;
  final String name;
  final String categoryId;
  final int priceCents;
  final int costCents;
  final int stock;

  /// Stock at or below this count raises a low-stock alert.
  final int reorderPoint;
  final bool taxable;

  StockLevel get level {
    if (stock <= 0) return StockLevel.out;
    if (stock <= reorderPoint) return StockLevel.low;
    return StockLevel.healthy;
  }

  int get stockValueCents => stock * costCents;

  /// Two letters for the tile, so the grid works with no product photos.
  String get monogram {
    final words = name
        .split(RegExp(r'\s+'))
        .where((word) => RegExp(r'^[A-Za-z]').hasMatch(word))
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final word = words.first;
      return word.length == 1
          ? word.toUpperCase()
          : '${word[0].toUpperCase()}${word[1].toLowerCase()}';
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Product copyWith({int? stock}) => Product(
    id: id,
    sku: sku,
    barcode: barcode,
    name: name,
    categoryId: categoryId,
    priceCents: priceCents,
    costCents: costCents,
    stock: stock ?? this.stock,
    reorderPoint: reorderPoint,
    taxable: taxable,
  );
}
