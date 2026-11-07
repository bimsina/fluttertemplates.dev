import 'package:flutter/material.dart';

import 'data/barcode_scanner.dart';
import 'data/card_terminal.dart';
import 'data/default_repository.dart';
import 'data/pos_repository.dart';
import 'data/receipt_printer.dart';
import 'screens/shell_screen.dart';
import 'state/pos_scope.dart';
import 'state/pos_store.dart';
import 'widgets/pos_theme.dart';

/// A complete point of sale register. Place it anywhere below a [MaterialApp],
/// for example `home: const RetailPosApp()`. It builds its own navigator, so it
/// also works as one section of a larger app.
///
/// Every outside dependency has a default for the demo and an interface for
/// the real thing. See the files in `data/`.
class RetailPosApp extends StatefulWidget {
  const RetailPosApp({
    super.key,
    this.repository,
    this.scanner,
    this.cardTerminal,
    this.receiptPrinter,
  });

  /// Defaults to `createDefaultRepository()` in `data/default_repository.dart`.
  final PosRepository? repository;

  /// Defaults to the manual code field.
  final BarcodeScanner? scanner;

  /// Defaults to a simulated terminal.
  final CardTerminal? cardTerminal;

  /// Defaults to a printer that formats the receipt and discards it.
  final ReceiptPrinter? receiptPrinter;

  @override
  State<RetailPosApp> createState() => _RetailPosAppState();
}

class _RetailPosAppState extends State<RetailPosApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  late final PosStore _store = PosStore(
    repository: widget.repository ?? createDefaultRepository(),
    scanner: widget.scanner ?? ManualBarcodeScanner(),
    cardTerminal: widget.cardTerminal ?? SimulatedCardTerminal(),
    receiptPrinter: widget.receiptPrinter ?? PreviewReceiptPrinter(),
  )..load();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PosTheme.resolve(Theme.of(context)),
      child: PosScope(
        store: _store,
        child: ScaffoldMessenger(
          child: NavigatorPopHandler<void>(
            onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const ShellScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
