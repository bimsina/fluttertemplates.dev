---
heroImage: "../../assets/template_images/retail-pos.png"
title: "Retail POS and Inventory App"
description: "Flutter point of sale template for tablets: product grid with categories and search, barcode entry behind a replaceable scanner interface, cart with quantity and discounts, cash and card payment, printable receipts, inventory with low-stock alerts, stock adjustments and a daily sales summary. Pure Flutter SDK, no packages."
summary: "A register, payments, receipts, stock control and a daily sales summary."
type: full-app
path: /templates/retail_pos
code_dir: templates/retail_pos
tags:
  [
    "point of sale",
    "pos",
    "retail",
    "inventory",
    "barcode",
    "receipt",
    "tablet",
    "cart",
    "sales report",
  ]
---

A working register for a small shop, built tablet-first and adapting down to phones. Every step of a sale is connected: selling a product decrements its stock, writes a ledger entry and shows up in the daily summary. The template has no dependencies beyond the Flutter SDK. Its data is in memory and resets on reload.

## What's included

- **Register:** product grid with category filters and search, plus a barcode field. Tiles show a monogram and shelf code instead of photos, so the grid works with a plain stock file.
- **Cart:** quantity steppers, per-line discounts, an order discount (percent or amount) and tax with exempt products. A cart line can never exceed available stock.
- **Payment:** cash with a keypad, quick amounts and change calculation. Card payment goes through a simulated terminal, with a switch to rehearse a decline. If the sale is recorded but the refresh after it fails, the receipt still appears, with a notice that stock and sales may be out of date and a Refresh button. If no answer comes back at all, the screen offers a retry that can only record the sale once and takes no new payment.
- **Receipt:** on-screen receipt with a scannable Code 39 barcode, plus a 42-column text layout for thermal printers. If the sale pushed a product to its reorder point, the screen says so.
- **Inventory:** stock levels sorted by urgency, low-stock and sold-out alerts, and stock value at cost.
- **Stock adjust:** receive, remove or recount, with a note and a per-product history of every movement.
- **Daily summary:** takings, net sales, transactions, average sale, takings by hour, cash against card, expected cash in the drawer, top products and every transaction, with reprint. A week of history is seeded.

Money is stored as integer cents throughout. Colours come from your app's `ColorScheme`, so light mode, dark mode and your seed colour all apply.

## Getting started

Copy `retail_pos` into your project and show the entry widget anywhere below a `MaterialApp`. All imports are relative, so the folder can live anywhere in `lib/`.

```dart
MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
  home: const RetailPosApp(),
);
```

`RetailPosApp` builds its own navigator, so it also works as one section of a larger app.

## Structure

```text
retail_pos/
  app.dart      Entry widget. Wires the defaults, theme and navigator.
  models/       Product, Cart (all pricing rules), Sale, StockMovement,
                DailySummary, money and date formatting.
  data/         PosRepository, BarcodeScanner, CardTerminal, ReceiptPrinter,
                their demo implementations, the seed data and the repository
                swap point.
  state/        PosStore (ChangeNotifier) and PosScope (InheritedNotifier).
  screens/      Shell, register, payment, receipt, inventory, stock adjust,
                sales.
  widgets/      Theme, product tile, till tape, keypad, receipt paper, charts,
                stale data notice.
```

Screens read the store with `PosScope.of(context)` and call its methods. Business rules stay out of widgets: pricing is in `models/cart.dart`, and stock changes happen only in the repository.

## Plugging in real services

Each outside dependency is an interface in `data/` and an optional argument on the entry widget. Nothing else in the app changes. The repository also has a default in `data/default_repository.dart`, covered under Backend.

```dart
RetailPosApp(
  repository: ApiPosRepository(client),
  scanner: WedgeBarcodeScanner(),
  cardTerminal: StripeCardTerminal(),
  receiptPrinter: EscPosReceiptPrinter(address),
);
```

### Barcode scanner

Implement `BarcodeScanner` in `data/barcode_scanner.dart`. The register only listens to the `scans` stream, so a typed code and a hardware scan take the same path.

- **USB or Bluetooth scanners** act as keyboards. Collect digits with `HardwareKeyboard.instance.addHandler` and emit a code on Enter.
- **Camera scanning** needs a package such as `mobile_scanner`. Forward its detections to `scans` and ignore repeats of the same code.
- **Devices with a built-in imager** usually report scans through a platform channel, which can feed the same stream.

Keep `enterManually` working for damaged labels. `start` and `stop` are called around payment, so a stray scan can't change an order being paid for.

The list button in the scan field offers sample barcodes for the demo. When you use real data, remove that `PopupMenuButton` and the `_samples` method from `widgets/scan_field.dart`, along with the imports they leave unused.

Errors on `scans` show as a warning beside the scan field, and scanning carries on.

### Receipt printer

Implement `ReceiptPrinter` in `data/receipt_printer.dart`. `formatReceipt` returns the receipt as fixed-width lines, 42 columns by default. Most 80mm thermal printers take those lines wrapped in ESC/POS commands, sent over the network, USB or Bluetooth. The message in `PrintResult` is shown to the cashier.

### Card payments

Implement `CardTerminal` in `data/card_terminal.dart` with your provider's SDK. `charge` returns a stream of events ending in `CardApproved` or `CardDeclined`, and the payment screen already handles each state. If the stream errors or ends without either, the screen tells the cashier to check the terminal before charging again. The decline switch appears only for `SimulatedCardTerminal`.

### Backend

1. Implement `PosRepository` in `data/pos_repository.dart`. Every method is asynchronous, so a REST API, SQLite or Firebase fits without UI changes.
2. Return it from `data/default_repository.dart`, in place of the in-memory one:

```dart
import 'api_pos_repository.dart';
import 'pos_repository.dart';

PosRepository createDefaultRepository() => ApiPosRepository(client);
```

3. Delete `data/in_memory_pos_repository.dart` and `data/seed_data.dart`.

`RetailPosApp(repository: ...)` overrides the default for one app instance, which is useful in tests. It doesn't replace step 2.

`commitSale` is the method to get right. It must record the sale and decrement stock in one transaction, and throw `InsufficientStockException` without writing anything if stock ran out.

It must also be idempotent on `SaleDraft.idempotencyKey`: a key that was already recorded returns the original sale and writes nothing, as `InMemoryPosRepository` does. `PosStore` generates one key per sale. Any error other than `InsufficientStockException`, or no answer within 30 seconds, counts as an unknown outcome: the store keeps the draft in `unresolvedSale`, and the cashier's retry resends it with the same key and the same payment. The retry is only safe if the server honors the key. The draft is held in memory, so persist it if a restart must not lose it. The cashier can stop retrying, which keeps the cart and warns them to check the Sales screen before charging again.

If the refresh after a sale fails or takes over 10 seconds, the sale still counts. `PosStore` applies it to stock and the sales list locally and sets `isDataStale` until a refresh works. Those figures are an estimate, not what the server reported.

`adjustStock` has no idempotency key. If it fails, the screen asks the cashier to check the stock history before trying again, because a change whose response was lost may have been applied.

Generate receipt numbers on the server, using only digits, `R` and `-`, or extend the table in `widgets/code39_barcode.dart`.

## Not included

There are no refunds, split payments, customer accounts, staff logins or offline sync. A card charge is taken before the sale is recorded, so with a real backend, void the charge if `commitSale` refuses the sale. The payment screen currently tells the cashier to do this by hand. After an unknown outcome the charge stands and the retry reuses it. If the cashier stops retrying instead, checking the terminal is up to them.
