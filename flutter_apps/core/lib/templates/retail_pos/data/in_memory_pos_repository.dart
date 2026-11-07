import '../models/product.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';
import '../models/store_profile.dart';
import 'pos_repository.dart';
import 'seed_data.dart';

/// Holds the demo store in memory. State resets on reload.
class InMemoryPosRepository implements PosRepository {
  /// Replays a week of seeded sales through the same code path as live sales,
  /// so the ledger and the daily summary hold real entries from the start.
  InMemoryPosRepository.seeded({DateTime? now})
    : _categories = seedCategories,
      _profile = seedStoreProfile {
    final clock = now ?? DateTime.now();
    final history = buildSeedHistory(
      seedProducts,
      clock,
      seedStoreProfile.taxRateBasisPoints,
    );

    // Opening stock is the seeded count plus whatever history will sell, which
    // leaves each product at its seeded count after the replay.
    final sold = <String, int>{};
    for (final draft in history) {
      for (final line in draft.lines) {
        sold[line.productId] = (sold[line.productId] ?? 0) + line.quantity;
      }
    }
    for (final product in seedProducts) {
      _products[product.id] = product.copyWith(
        stock: product.stock + (sold[product.id] ?? 0),
      );
    }
    history.forEach(_commit);
  }

  final List<ProductCategory> _categories;
  final StoreProfile _profile;
  final Map<String, Product> _products = {};
  final List<Sale> _sales = [];
  final List<StockMovement> _movements = [];
  final Map<String, Sale> _salesByKey = {};
  int _nextReceipt = 1042;

  @override
  Future<StoreProfile> fetchStoreProfile() async => _profile;

  @override
  Future<List<ProductCategory>> fetchCategories() async => _categories;

  @override
  Future<List<Product>> fetchProducts() async =>
      _products.values.toList(growable: false);

  @override
  Future<Product?> findByBarcode(String barcode) async {
    for (final product in _products.values) {
      if (product.barcode == barcode) return product;
    }
    return null;
  }

  @override
  Future<List<Sale>> fetchSales() async => List.unmodifiable(_sales);

  @override
  Future<Sale> commitSale(SaleDraft draft) async => _commit(draft);

  Sale _commit(SaleDraft draft) {
    // Checked before validation: a replay must return the original sale even
    // if the shelf can no longer cover it.
    final recorded = _salesByKey[draft.idempotencyKey];
    if (recorded != null) return recorded;

    // Validate every line before touching anything, so a failure writes
    // nothing. The same product can only appear on one cart line.
    final short = [
      for (final line in draft.lines)
        if ((_products[line.productId]?.stock ?? 0) < line.quantity) line.name,
    ];
    if (short.isNotEmpty) throw InsufficientStockException(short);

    final createdAt = draft.createdAt ?? DateTime.now();
    final sale = Sale(
      receiptNumber: 'R-${(_nextReceipt++).toString().padLeft(6, '0')}',
      createdAt: createdAt,
      lines: draft.lines,
      totals: draft.totals,
      payment: draft.payment,
      orderDiscountLabel: draft.orderDiscountLabel,
    );

    for (final line in draft.lines) {
      final product = _products[line.productId]!;
      final updated = product.copyWith(stock: product.stock - line.quantity);
      _products[product.id] = updated;
      _movements.add(
        StockMovement(
          productId: product.id,
          delta: -line.quantity,
          stockAfter: updated.stock,
          reason: StockMovementReason.sale,
          createdAt: createdAt,
          note: sale.receiptNumber,
        ),
      );
    }
    _sales.add(sale);
    _salesByKey[draft.idempotencyKey] = sale;
    return sale;
  }

  @override
  Future<Product> adjustStock({
    required String productId,
    required int delta,
    required StockMovementReason reason,
    String? note,
  }) async {
    final product = _products[productId];
    if (product == null) throw ArgumentError('Unknown product $productId');
    final next = product.stock + delta;
    if (next < 0) throw ArgumentError('Stock cannot go below zero');

    final updated = product.copyWith(stock: next);
    _products[productId] = updated;
    _movements.add(
      StockMovement(
        productId: productId,
        delta: delta,
        stockAfter: next,
        reason: reason,
        createdAt: DateTime.now(),
        note: note,
      ),
    );
    return updated;
  }

  @override
  Future<List<StockMovement>> fetchMovements(String productId) async =>
      _movements.reversed
          .where((movement) => movement.productId == productId)
          .toList(growable: false);
}
