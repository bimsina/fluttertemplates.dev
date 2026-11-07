import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/barcode_scanner.dart';
import '../data/card_terminal.dart';
import '../data/pos_repository.dart';
import '../data/receipt_printer.dart';
import '../models/cart.dart';
import '../models/daily_summary.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';
import '../models/store_profile.dart';

enum ScanOutcome { added, warning, notFound }

/// The result of the latest scan, shown beside the scan field.
class ScanFeedback {
  const ScanFeedback(this.outcome, this.message);

  final ScanOutcome outcome;
  final String message;
}

class CheckoutResult {
  const CheckoutResult({
    required this.sale,
    required this.lowStock,
    this.isDataFresh = true,
  });

  final Sale sale;

  /// Products from this sale now at or below their reorder point.
  final List<Product> lowStock;

  /// False when the refresh after the sale failed. The sale still happened,
  /// but [PosStore.products] and [PosStore.sales] hold a local estimate.
  final bool isDataFresh;
}

/// No answer came back for a sale, so it may or may not be recorded. The cart
/// and [PosStore.unresolvedSale] stay as they were. Calling
/// [PosStore.completeSale] again is safe, and charges nothing new.
class SaleOutcomeUnknownException implements Exception {
  const SaleOutcomeUnknownException(this.cause);

  final Object cause;

  @override
  String toString() => 'Sale outcome unknown: $cause';
}

/// The single source of truth for the register. Screens read it through
/// `PosScope.of(context)` and call its methods; they never hold business state.
class PosStore extends ChangeNotifier {
  /// How long a sale may go unanswered before its outcome counts as unknown.
  static const Duration commitTimeout = Duration(seconds: 30);

  /// How long a refresh may hold up the receipt after a sale.
  static const Duration refreshTimeout = Duration(seconds: 10);

  PosStore({
    required this.repository,
    required this.scanner,
    required this.cardTerminal,
    required this.receiptPrinter,
  }) {
    _scanSubscription = scanner.scans.listen(_onScan, onError: _onScanError);
  }

  final PosRepository repository;
  final BarcodeScanner scanner;
  final CardTerminal cardTerminal;
  final ReceiptPrinter receiptPrinter;

  late final StreamSubscription<String> _scanSubscription;
  Timer? _feedbackTimer;
  bool _disposed = false;

  bool _isLoading = true;
  Object? _loadError;
  late StoreProfile _profile;
  List<ProductCategory> _categories = const [];
  List<Product> _products = const [];
  List<Sale> _sales = const [];
  Cart _cart = const Cart();
  ScanFeedback? _scanFeedback;
  SaleDraft? _unresolvedSale;
  bool _isDataStale = false;

  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;
  StoreProfile get profile => _profile;
  List<ProductCategory> get categories => _categories;
  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  Cart get cart => _cart;
  ScanFeedback? get scanFeedback => _scanFeedback;

  /// A sale whose outcome is unknown. [completeSale] resends it, key and
  /// payment included, until the repository gives an answer.
  SaleDraft? get unresolvedSale => _unresolvedSale;

  /// True after a refresh failed, until one succeeds. Stock and the sales
  /// list may not match the repository in the meantime.
  bool get isDataStale => _isDataStale;

  CartTotals get totals => _cart.totals(_profile.taxRateBasisPoints);

  /// Products at or below their reorder point, including sold out ones.
  List<Product> get alerts => _products
      .where((product) => product.level != StockLevel.healthy)
      .toList(growable: false);

  /// Cart lines asking for more than is on the shelf. This can happen when
  /// stock is adjusted down while a sale is open. Checkout stays blocked until
  /// the cashier resolves them.
  List<CartLine> get stockIssues => _cart.lines
      .where((line) => line.quantity > line.product.stock)
      .toList(growable: false);

  bool get canCheckout => !_cart.isEmpty && stockIssues.isEmpty;

  int categoryIndex(String categoryId) =>
      _categories.indexWhere((category) => category.id == categoryId);

  /// Stock left once the open cart is taken into account.
  int availableOf(Product product) =>
      product.stock - _cart.quantityOf(product.id);

  DailySummary summaryFor(DateTime day) => DailySummary.forDay(day, _sales);

  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    _notify();
    try {
      _profile = await repository.fetchStoreProfile();
      _categories = await repository.fetchCategories();
      _products = await repository.fetchProducts();
      _sales = await repository.fetchSales();
      _isDataStale = false;
      await scanner.start();
    } catch (error) {
      _loadError = error;
    }
    _isLoading = false;
    _notify();
  }

  // Cart

  void addToCart(Product product) {
    if (availableOf(product) <= 0) {
      _setFeedback(
        ScanOutcome.warning,
        product.stock <= 0
            ? '${product.name} is out of stock'
            : 'All ${product.stock} ${product.name} are already in this sale',
      );
      return;
    }
    _cart = _cart.add(product);
    _setFeedback(ScanOutcome.added, 'Added ${product.name}');
  }

  void setQuantity(Product product, int quantity) {
    if (quantity > product.stock) {
      _setFeedback(ScanOutcome.warning, 'Only ${product.stock} in stock');
      quantity = product.stock;
    }
    _cart = _cart.setQuantity(product.id, quantity);
    _notify();
  }

  void removeLine(Product product) {
    _cart = _cart.setQuantity(product.id, 0);
    _notify();
  }

  void setLineDiscount(Product product, Discount discount) {
    _cart = _cart.setLineDiscount(product.id, discount);
    _notify();
  }

  void setOrderDiscount(Discount discount) {
    _cart = _cart.setOrderDiscount(discount);
    _notify();
  }

  void clearCart() {
    _cart = const Cart();
    _notify();
  }

  // Scanning

  Future<void> _onScan(String code) async {
    final Product? product;
    try {
      product = await repository.findByBarcode(code);
    } catch (error, stackTrace) {
      debugPrint('Barcode lookup failed: $error\n$stackTrace');
      if (!_disposed) {
        _setFeedback(ScanOutcome.warning, 'Could not look up code $code');
      }
      return;
    }
    if (_disposed) return;
    if (product == null) {
      _setFeedback(ScanOutcome.notFound, 'No product for code $code');
      return;
    }
    addToCart(product);
  }

  void _onScanError(Object error, StackTrace stackTrace) {
    debugPrint('Scanner failed: $error\n$stackTrace');
    if (_disposed) return;
    _setFeedback(
      ScanOutcome.warning,
      'Scanner error. Check it, or type the code.',
    );
  }

  void _setFeedback(ScanOutcome outcome, String message) {
    _scanFeedback = ScanFeedback(outcome, message);
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      _scanFeedback = null;
      _notify();
    });
    _notify();
  }

  // Checkout

  /// Records the sale, which decrements stock, then clears the cart.
  ///
  /// The commit and the refresh after it report separately. Once the sale is
  /// recorded this returns normally whatever the refresh does, with
  /// [CheckoutResult.isDataFresh] false if the refresh failed.
  ///
  /// Throws [InsufficientStockException] if stock ran out, which changes
  /// nothing. Any other failure throws [SaleOutcomeUnknownException] and keeps
  /// the draft in [unresolvedSale]. While one is held, [payment] is ignored and
  /// the held draft is sent again with the same key.
  Future<CheckoutResult> completeSale(Payment payment) async {
    final draft =
        _unresolvedSale ??
        SaleDraft.fromCart(
          _cart,
          idempotencyKey: generateSaleKey(),
          totals: totals,
          payment: payment,
        );
    if (draft.lines.isEmpty) throw StateError('The cart is empty');

    final Sale sale;
    try {
      sale = await repository.commitSale(draft).timeout(commitTimeout);
    } on InsufficientStockException {
      _unresolvedSale = null;
      _notify();
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Sale outcome unknown: $error\n$stackTrace');
      _unresolvedSale = draft;
      _notify();
      throw SaleOutcomeUnknownException(error);
    }

    // The sale is recorded. Nothing after this line may read as a failure.
    _unresolvedSale = null;
    _cart = const Cart();
    final refreshed = await _tryRefresh();
    if (!refreshed) _applyCommittedSale(sale);

    final soldIds = sale.lines.map((line) => line.productId).toSet();
    final lowStock = alerts
        .where((product) => soldIds.contains(product.id))
        .toList(growable: false);
    _notify();
    return CheckoutResult(
      sale: sale,
      lowStock: lowStock,
      isDataFresh: refreshed,
    );
  }

  /// Stops retrying a sale with an unknown outcome and keeps the cart. The
  /// sale may still be recorded, so the screen has to warn before this.
  void abandonUnresolvedSale() {
    if (_unresolvedSale == null) return;
    _unresolvedSale = null;
    _notify();
  }

  /// Reloads stock and sales in place and returns whether that worked. A
  /// failure keeps the current data on screen and marks it stale.
  Future<bool> refresh() async {
    final refreshed = await _tryRefresh();
    _notify();
    return refreshed;
  }

  Future<bool> _tryRefresh() async {
    try {
      final (products, sales) = await (
        repository.fetchProducts(),
        repository.fetchSales(),
      ).wait.timeout(refreshTimeout);
      _products = products;
      _sales = sales;
      final byId = {for (final product in products) product.id: product};
      _cart = _cart.refreshProducts((id) => byId[id]);
      _isDataStale = false;
      return true;
    } catch (error, stackTrace) {
      debugPrint('POS refresh failed: $error\n$stackTrace');
      _isDataStale = true;
      return false;
    }
  }

  /// Local estimate of a sale the refresh couldn't fetch, so stock alerts and
  /// the daily summary include it. A sale already in the list came from the
  /// repository, and its stock change is already counted.
  void _applyCommittedSale(Sale sale) {
    if (_sales.any((known) => known.receiptNumber == sale.receiptNumber)) {
      return;
    }
    _sales = [..._sales, sale];
    final sold = {for (final line in sale.lines) line.productId: line.quantity};
    _products = [
      for (final product in _products)
        sold.containsKey(product.id)
            ? product.copyWith(stock: product.stock - sold[product.id]!)
            : product,
    ];
  }

  // Inventory

  Future<void> adjustStock({
    required Product product,
    required int delta,
    required StockMovementReason reason,
    String? note,
  }) async {
    final updated = await repository.adjustStock(
      productId: product.id,
      delta: delta,
      reason: reason,
      note: note,
    );
    _products = [
      for (final item in _products) item.id == updated.id ? updated : item,
    ];
    _cart = _cart.refreshProducts((id) => id == updated.id ? updated : null);
    _notify();
  }

  Product productById(String id) =>
      _products.firstWhere((product) => product.id == id);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _feedbackTimer?.cancel();
    _scanSubscription.cancel();
    scanner.dispose();
    super.dispose();
  }
}
