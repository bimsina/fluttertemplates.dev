import 'dart:async';

import 'package:core/templates/retail_pos/app.dart';
import 'package:core/templates/retail_pos/data/barcode_scanner.dart';
import 'package:core/templates/retail_pos/data/card_terminal.dart';
import 'package:core/templates/retail_pos/data/in_memory_pos_repository.dart';
import 'package:core/templates/retail_pos/data/pos_repository.dart';
import 'package:core/templates/retail_pos/data/receipt_printer.dart';
import 'package:core/templates/retail_pos/models/cart.dart';
import 'package:core/templates/retail_pos/models/product.dart';
import 'package:core/templates/retail_pos/models/sale.dart';
import 'package:core/templates/retail_pos/models/stock_movement.dart';
import 'package:core/templates/retail_pos/models/store_profile.dart';
import 'package:core/templates/retail_pos/screens/payment_screen.dart';
import 'package:core/templates/retail_pos/screens/receipt_screen.dart';
import 'package:core/templates/retail_pos/screens/stock_adjust_screen.dart';
import 'package:core/templates/retail_pos/state/pos_scope.dart';
import 'package:core/templates/retail_pos/state/pos_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The in-memory store with switches for each way a real backend can fail.
class FaultyPosRepository extends InMemoryPosRepository {
  FaultyPosRepository() : super.seeded();

  int failProductReads = 0;
  bool hangNextProductRead = false;
  bool loseNextCommit = false;
  bool hangNextCommit = false;
  bool failLookups = false;
  bool failAdjust = false;
  final commitKeys = <String>[];

  @override
  Future<List<Product>> fetchProducts() {
    if (hangNextProductRead) {
      hangNextProductRead = false;
      return Completer<List<Product>>().future;
    }
    if (failProductReads > 0) {
      failProductReads--;
      return Future.error(StateError('products offline'));
    }
    return super.fetchProducts();
  }

  @override
  Future<Sale> commitSale(SaleDraft draft) async {
    commitKeys.add(draft.idempotencyKey);
    if (hangNextCommit) {
      hangNextCommit = false;
      return Completer<Sale>().future;
    }
    final sale = await super.commitSale(draft);
    if (loseNextCommit) {
      loseNextCommit = false;
      throw TimeoutException('The response was lost');
    }
    return sale;
  }

  @override
  Future<Product?> findByBarcode(String barcode) {
    if (failLookups) return Future.error(StateError('lookup offline'));
    return super.findByBarcode(barcode);
  }

  @override
  Future<Product> adjustStock({
    required String productId,
    required int delta,
    required StockMovementReason reason,
    String? note,
  }) {
    if (failAdjust) return Future.error(StateError('adjust offline'));
    return super.adjustStock(
      productId: productId,
      delta: delta,
      reason: reason,
      note: note,
    );
  }
}

/// A scanner whose stream can fail, as a hardware connection can.
class FaultyScanner extends ManualBarcodeScanner {
  final events = StreamController<String>.broadcast();

  @override
  Stream<String> get scans => events.stream;
}

/// Emits whatever the test sends, and ends when the test closes it.
class ScriptedTerminal implements CardTerminal {
  final events = StreamController<CardEvent>();

  @override
  Stream<CardEvent> charge(int amountCents) => events.stream;

  @override
  Future<void> cancel() async {}
}

class BrokenPrinter implements ReceiptPrinter {
  @override
  Future<PrintResult> printReceipt(Sale sale, StoreProfile store) =>
      Future.error(StateError('printer offline'));
}

PosStore storeFor(
  PosRepository repository, {
  BarcodeScanner? scanner,
  CardTerminal? terminal,
  ReceiptPrinter? printer,
}) => PosStore(
  repository: repository,
  scanner: scanner ?? ManualBarcodeScanner(),
  cardTerminal: terminal ?? SimulatedCardTerminal(),
  receiptPrinter: printer ?? PreviewReceiptPrinter(),
);

Product stocked(PosStore store) =>
    store.products.firstWhere((product) => product.stock > 2);

Payment exactCash(PosStore store) =>
    CashPayment(tenderedCents: store.totals.totalCents, changeCents: 0);

Future<int> stockOf(PosRepository repository, String id) async =>
    (await repository.fetchProducts()).firstWhere((p) => p.id == id).stock;

/// Mounts the store with a home route, then pushes [screen] above it.
Future<void> pumpOver(
  WidgetTester tester,
  PosStore store,
  Widget screen,
) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigator,
      builder: (context, child) => PosScope(store: store, child: child!),
      home: const Scaffold(body: Text('Register')),
    ),
  );
  navigator.currentState!.push(MaterialPageRoute<void>(builder: (_) => screen));
  await settle(tester);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> unmount(WidgetTester tester, PosStore store) async {
  await tester.pumpWidget(const SizedBox());
  store.dispose();
}

Future<void> payExact(WidgetTester tester) async {
  await tester.tap(find.text('Exact'));
  await tester.pump();
  await tester.tap(find.text('Complete sale'));
  await settle(tester);
}

void main() {
  group('a sale that committed', () {
    test('survives a failed refresh, with a local estimate', () async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      addTearDown(store.dispose);
      await store.load();
      final product = stocked(store);
      store.addToCart(product);
      final salesBefore = store.sales.length;

      repository.failProductReads = 1;
      final result = await store.completeSale(exactCash(store));

      expect(result.isDataFresh, isFalse);
      expect(store.isDataStale, isTrue);
      expect(store.cart.isEmpty, isTrue);
      expect(store.unresolvedSale, isNull);
      expect(await repository.fetchSales(), hasLength(salesBefore + 1));
      // What the screens show includes the sale, without any refresh.
      expect(store.sales, hasLength(salesBefore + 1));
      expect(store.productById(product.id).stock, product.stock - 1);
    });

    test('a later refresh clears the stale flag and adds nothing', () async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      addTearDown(store.dispose);
      await store.load();
      final product = stocked(store);
      store.addToCart(product);
      repository.failProductReads = 1;
      await store.completeSale(exactCash(store));
      final salesAfter = store.sales.length;

      expect(await store.refresh(), isTrue);

      expect(store.isDataStale, isFalse);
      expect(store.sales, hasLength(salesAfter));
      expect(store.productById(product.id).stock, product.stock - 1);
    });

    test('a failed manual refresh keeps the data and flags it', () async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      addTearDown(store.dispose);
      await store.load();
      final products = store.products;

      repository.failProductReads = 1;
      expect(await store.refresh(), isFalse);

      expect(store.isDataStale, isTrue);
      expect(store.products, same(products));
    });

    testWidgets('survives a refresh that never answers', (tester) async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));

      repository.hangNextProductRead = true;
      final sale = store.completeSale(exactCash(store));
      await tester.pump(PosStore.refreshTimeout + const Duration(seconds: 1));

      expect((await sale).isDataFresh, isFalse);
      expect(store.cart.isEmpty, isTrue);
      store.dispose();
    });

    test(
      'reports low stock from the estimate when the refresh fails',
      () async {
        final repository = FaultyPosRepository();
        final store = storeFor(repository);
        addTearDown(store.dispose);
        await store.load();
        final product = store.products.firstWhere(
          (p) => p.level == StockLevel.healthy && p.stock > p.reorderPoint,
        );
        store
          ..addToCart(product)
          ..setQuantity(product, product.stock - product.reorderPoint);

        repository.failProductReads = 1;
        final result = await store.completeSale(exactCash(store));

        expect(result.lowStock.map((p) => p.id), contains(product.id));
      },
    );
  });

  group('a sale with an unknown outcome', () {
    test('keeps the cart and retries once with the same key', () async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      addTearDown(store.dispose);
      await store.load();
      final product = stocked(store);
      store.addToCart(product);
      final salesBefore = store.sales.length;
      final payment = exactCash(store);

      repository.loseNextCommit = true;
      await expectLater(
        store.completeSale(payment),
        throwsA(isA<SaleOutcomeUnknownException>()),
      );
      expect(store.cart.isEmpty, isFalse);
      expect(store.unresolvedSale, isNotNull);

      final retried = await store.completeSale(payment);

      expect(repository.commitKeys.toSet(), hasLength(1));
      expect(repository.commitKeys, hasLength(2));
      expect(retried.sale.lines.single.productId, product.id);
      expect(await repository.fetchSales(), hasLength(salesBefore + 1));
      expect(await stockOf(repository, product.id), product.stock - 1);
      expect(store.cart.isEmpty, isTrue);
      expect(store.unresolvedSale, isNull);
    });

    test('resends the payment already taken, whatever is passed', () async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      addTearDown(store.dispose);
      await store.load();
      store.addToCart(stocked(store));
      const card = CardPayment(
        brand: 'Visa',
        last4: '4242',
        authCode: '123456',
      );

      repository.loseNextCommit = true;
      await expectLater(
        store.completeSale(card),
        throwsA(isA<SaleOutcomeUnknownException>()),
      );
      final retried = await store.completeSale(exactCash(store));

      expect(retried.sale.payment, same(card));
    });

    testWidgets('includes a commit that never answers', (tester) async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));

      repository.hangNextCommit = true;
      final sale = store.completeSale(exactCash(store));
      final failure = expectLater(
        sale,
        throwsA(isA<SaleOutcomeUnknownException>()),
      );
      await tester.pump(PosStore.commitTimeout + const Duration(seconds: 1));
      await failure;

      expect(store.unresolvedSale, isNotNull);
      store.dispose();
    });

    test('abandoning keeps the cart and starts a new key', () async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      addTearDown(store.dispose);
      await store.load();
      store.addToCart(stocked(store));

      repository.loseNextCommit = true;
      await expectLater(
        store.completeSale(exactCash(store)),
        throwsA(isA<SaleOutcomeUnknownException>()),
      );
      store.abandonUnresolvedSale();

      expect(store.unresolvedSale, isNull);
      expect(store.cart.isEmpty, isFalse);
      await store.completeSale(exactCash(store));
      expect(repository.commitKeys.toSet(), hasLength(2));
    });
  });

  group('InMemoryPosRepository idempotency', () {
    SaleDraft draft(String key, Product product, int quantity) => SaleDraft(
      idempotencyKey: key,
      lines: [
        SaleLine(
          productId: product.id,
          name: product.name,
          unitPriceCents: product.priceCents,
          quantity: quantity,
          discountCents: 0,
          discountLabel: null,
        ),
      ],
      totals: const CartTotals(
        grossCents: 0,
        lineDiscountCents: 0,
        orderDiscountCents: 0,
        taxCents: 0,
      ),
      payment: const CashPayment(tenderedCents: 0, changeCents: 0),
    );

    test('replays a key without writing, even with no stock left', () async {
      final repository = InMemoryPosRepository.seeded();
      final product = (await repository.fetchProducts()).firstWhere(
        (p) => p.stock > 0,
      );
      final sale = draft('key', product, product.stock);
      final first = await repository.commitSale(sale);
      final salesAfter = (await repository.fetchSales()).length;
      final movesAfter = (await repository.fetchMovements(product.id)).length;

      final replay = await repository.commitSale(sale);

      expect(replay, same(first));
      expect(await repository.fetchSales(), hasLength(salesAfter));
      expect(
        await repository.fetchMovements(product.id),
        hasLength(movesAfter),
      );
      expect(await stockOf(repository, product.id), 0);
    });

    test('a new key is a new sale', () async {
      final repository = InMemoryPosRepository.seeded();
      final product = (await repository.fetchProducts()).firstWhere(
        (p) => p.stock > 1,
      );

      final first = await repository.commitSale(draft('a', product, 1));
      final second = await repository.commitSale(draft('b', product, 1));

      expect(second.receiptNumber, isNot(first.receiptNumber));
      expect(await stockOf(repository, product.id), product.stock - 2);
    });

    test('a refused sale can be sent again under the same key', () async {
      final repository = InMemoryPosRepository.seeded();
      final product = (await repository.fetchProducts()).firstWhere(
        (p) => p.stock > 0,
      );
      final tooMany = draft('key', product, product.stock + 1);

      await expectLater(
        repository.commitSale(tooMany),
        throwsA(isA<InsufficientStockException>()),
      );
      await repository.adjustStock(
        productId: product.id,
        delta: 1,
        reason: StockMovementReason.received,
      );

      await repository.commitSale(tooMany);
      expect(await stockOf(repository, product.id), 0);
    });
  });

  test('every sale gets its own key', () async {
    final repository = FaultyPosRepository();
    final store = storeFor(repository);
    addTearDown(store.dispose);
    await store.load();
    final product = stocked(store);

    store.addToCart(product);
    await store.completeSale(exactCash(store));
    store.addToCart(store.productById(product.id));
    await store.completeSale(exactCash(store));

    expect(repository.commitKeys.toSet(), hasLength(2));
  });

  test('running out of stock changes nothing and holds no sale', () async {
    final repository = FaultyPosRepository();
    final store = storeFor(repository);
    addTearDown(store.dispose);
    await store.load();
    final product = stocked(store);
    store.addToCart(product);
    await repository.adjustStock(
      productId: product.id,
      delta: -product.stock,
      reason: StockMovementReason.removed,
    );

    await expectLater(
      store.completeSale(exactCash(store)),
      throwsA(isA<InsufficientStockException>()),
    );

    expect(store.unresolvedSale, isNull);
    expect(store.cart.isEmpty, isFalse);
  });

  test('an empty cart can\'t record a sale', () async {
    final repository = FaultyPosRepository();
    final store = storeFor(repository);
    addTearDown(store.dispose);
    await store.load();
    final salesBefore = (await repository.fetchSales()).length;

    await expectLater(
      store.completeSale(const CashPayment(tenderedCents: 0, changeCents: 0)),
      throwsStateError,
    );

    expect(await repository.fetchSales(), hasLength(salesBefore));
  });

  group('payment screen', () {
    testWidgets('a failed refresh still shows the receipt, with a notice', (
      tester,
    ) async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));
      await pumpOver(tester, store, const PaymentScreen());

      repository.failProductReads = 1;
      await payExact(tester);

      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(find.text('Sale complete'), findsOneWidget);
      expect(find.textContaining('may be out of date'), findsOneWidget);
      expect(store.cart.isEmpty, isTrue);

      await tester.tap(find.text('Refresh'));
      await settle(tester);
      expect(find.textContaining('may be out of date'), findsNothing);
      await unmount(tester, store);
    });

    testWidgets('a fresh sale shows no stale notice', (tester) async {
      final store = storeFor(FaultyPosRepository());
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));
      await pumpOver(tester, store, const PaymentScreen());

      await payExact(tester);

      expect(find.text('Sale complete'), findsOneWidget);
      expect(find.textContaining('may be out of date'), findsNothing);
      await unmount(tester, store);
    });

    testWidgets('an unknown outcome blocks back and offers a safe retry', (
      tester,
    ) async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));
      final salesBefore = store.sales.length;
      await pumpOver(tester, store, const PaymentScreen());

      repository.loseNextCommit = true;
      await payExact(tester);

      expect(find.text('Retry sale'), findsOneWidget);
      expect(find.text('Complete sale'), findsNothing);
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, false);

      await tester.tap(find.text('Retry sale'));
      await settle(tester);

      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(store.sales, hasLength(salesBefore + 1));
      await unmount(tester, store);
    });

    testWidgets('stopping retries warns, then returns with the cart', (
      tester,
    ) async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));
      await pumpOver(tester, store, const PaymentScreen());
      repository.loseNextCommit = true;
      await payExact(tester);

      await tester.tap(find.text('Stop retrying'));
      await settle(tester);
      expect(find.text('Stop retrying this sale?'), findsOneWidget);
      await tester.tap(find.text('Stop retrying').last);
      await settle(tester);

      expect(find.text('Register'), findsOneWidget);
      expect(store.unresolvedSale, isNull);
      expect(store.cart.isEmpty, isFalse);
      await unmount(tester, store);
    });

    Future<(PosStore, ScriptedTerminal)> startCard(WidgetTester tester) async {
      final terminal = ScriptedTerminal();
      final store = storeFor(FaultyPosRepository(), terminal: terminal);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));
      await pumpOver(tester, store, const PaymentScreen());
      await tester.tap(find.text('Card'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Charge card'));
      await tester.pump();
      return (store, terminal);
    }

    testWidgets('a terminal error unlocks the screen', (tester) async {
      final (store, terminal) = await startCard(tester);
      terminal.events.add(const CardWaiting());
      await tester.pump();
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, false);

      terminal.events.addError(StateError('terminal offline'));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('stopped responding'), findsOneWidget);
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, true);
      await unmount(tester, store);
    });

    testWidgets('a charge that ends with no result unlocks the screen', (
      tester,
    ) async {
      final (store, terminal) = await startCard(tester);
      terminal.events.add(const CardWaiting());
      await tester.pump();

      await terminal.events.close();
      await settle(tester);

      expect(find.textContaining('stopped responding'), findsOneWidget);
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, true);
      await unmount(tester, store);
    });
  });

  group('scanning', () {
    test('a scanner stream error becomes feedback', () async {
      final scanner = FaultyScanner();
      final store = storeFor(FaultyPosRepository(), scanner: scanner);
      addTearDown(store.dispose);
      await store.load();

      scanner.events.addError(StateError('scanner unplugged'));
      await pumpEventQueue();

      expect(store.scanFeedback?.outcome, ScanOutcome.warning);
      expect(store.scanFeedback?.message, contains('Scanner error'));
    });

    test('a failed lookup becomes feedback', () async {
      final repository = FaultyPosRepository()..failLookups = true;
      final scanner = FaultyScanner();
      final store = storeFor(repository, scanner: scanner);
      addTearDown(store.dispose);
      await store.load();

      scanner.events.add('12345');
      await pumpEventQueue();

      expect(store.scanFeedback?.message, 'Could not look up code 12345');
    });
  });

  group('at 320px with 200% text', () {
    void narrow(WidgetTester tester) {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }

    testWidgets('the unresolved sale panel and receipt notice fit', (
      tester,
    ) async {
      final repository = FaultyPosRepository();
      final store = storeFor(repository);
      await tester.runAsync(store.load);
      store.addToCart(stocked(store));
      await pumpOver(tester, store, const PaymentScreen());
      narrow(tester);
      await settle(tester);
      expect(tester.takeException(), isNull);

      repository.loseNextCommit = true;
      await tester.runAsync(() async {
        await expectLater(
          store.completeSale(exactCash(store)),
          throwsA(isA<SaleOutcomeUnknownException>()),
        );
      });
      await tester.pumpWidget(const SizedBox());
      await pumpOver(tester, store, const PaymentScreen());
      narrow(tester);
      await settle(tester);
      expect(find.text('Retry sale'), findsOneWidget);
      expect(tester.takeException(), isNull);

      repository.failProductReads = 1;
      await tester.ensureVisible(find.text('Retry sale'));
      await settle(tester);
      await tester.tap(find.text('Retry sale'));
      await tester.pump();
      // The sale and refresh use real timers, which the test clock doesn't run.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await settle(tester);
      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(find.textContaining('may be out of date'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester, store);
    });

    testWidgets('the shell shows the notice without overflowing', (
      tester,
    ) async {
      final repository = FaultyPosRepository();
      narrow(tester);
      await tester.pumpWidget(
        MaterialApp(home: RetailPosApp(repository: repository)),
      );
      await settle(tester);
      final store = PosScope.read(tester.element(find.byType(Scaffold).first));

      repository.failProductReads = 1;
      await tester.runAsync(store.refresh);
      await settle(tester);

      expect(find.textContaining('may be out of date'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  });

  testWidgets('a printer fault leaves the receipt usable', (tester) async {
    final repository = FaultyPosRepository();
    final store = storeFor(repository, printer: BrokenPrinter());
    await tester.runAsync(store.load);
    store.addToCart(stocked(store));
    await pumpOver(tester, store, const PaymentScreen());
    await payExact(tester);

    await tester.tap(find.text('Print receipt'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.text('Could not print the receipt. Try again.'),
      findsOneWidget,
    );
    await unmount(tester, store);
  });

  testWidgets('a failed stock adjustment unlocks the form', (tester) async {
    final repository = FaultyPosRepository()..failAdjust = true;
    final store = storeFor(repository);
    await tester.runAsync(store.load);
    await pumpOver(
      tester,
      store,
      StockAdjustScreen(productId: stocked(store).id),
    );

    await tester.enterText(find.byType(TextField).first, '3');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('Could not confirm that change'),
      findsOneWidget,
    );
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(save.onPressed, isNotNull);
    await unmount(tester, store);
  });
}
