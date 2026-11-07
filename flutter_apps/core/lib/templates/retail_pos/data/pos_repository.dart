import '../models/product.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';
import '../models/store_profile.dart';

/// Thrown by [PosRepository.commitSale] when a line exceeds available stock.
/// Nothing is written when this is thrown.
class InsufficientStockException implements Exception {
  const InsufficientStockException(this.productNames);

  final List<String> productNames;

  @override
  String toString() => 'Not enough stock for ${productNames.join(', ')}';
}

/// Everything the app needs from a data source. Every method is asynchronous
/// so a REST, SQLite or Firebase implementation drops in without UI changes.
/// Pass your implementation to `RetailPosApp(repository: ...)`.
abstract interface class PosRepository {
  Future<StoreProfile> fetchStoreProfile();

  Future<List<ProductCategory>> fetchCategories();

  Future<List<Product>> fetchProducts();

  Future<Product?> findByBarcode(String barcode);

  Future<List<Sale>> fetchSales();

  /// Records the sale and decrements stock as one atomic step. On a server
  /// this should be a single transaction.
  ///
  /// Must be idempotent on [SaleDraft.idempotencyKey]: a key that was already
  /// recorded returns the original sale and writes nothing.
  ///
  /// Throw [InsufficientStockException] only when nothing was written. Any
  /// other error, such as a timeout, is treated as an unknown outcome, and the
  /// same draft is sent again if the cashier retries.
  Future<Sale> commitSale(SaleDraft draft);

  /// Applies [delta] to a product's stock and writes a ledger entry.
  Future<Product> adjustStock({
    required String productId,
    required int delta,
    required StockMovementReason reason,
    String? note,
  });

  /// Newest first.
  Future<List<StockMovement>> fetchMovements(String productId);
}
