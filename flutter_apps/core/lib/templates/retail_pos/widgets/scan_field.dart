import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/pos_scope.dart';
import '../state/pos_store.dart';

/// Keyed barcode entry. It talks to the scanner interface, so the rest of the
/// register cannot tell a typed code from a hardware scan.
class ScanField extends StatefulWidget {
  const ScanField({super.key});

  @override
  State<ScanField> createState() => _ScanFieldState();
}

class _ScanFieldState extends State<ScanField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String code) {
    PosScope.read(context).scanner.enterManually(code);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmitted: _submit,
      decoration: InputDecoration(
        hintText: 'Scan or key a barcode',
        prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Sample barcodes',
          icon: const Icon(Icons.format_list_numbered_rounded, size: 20),
          onSelected: _submit,
          itemBuilder: (context) => [
            for (final product in _samples(context))
              PopupMenuItem(
                value: product.barcode,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(product.barcode),
                  subtitle: Text(product.name),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Demo helper: nobody has these barcodes at hand. Remove with real data.
  /// Includes a sold out product, so the refusal can be tried too.
  List<Product> _samples(BuildContext context) {
    final products = PosScope.read(context).products;
    return [
      ...products.where((p) => p.level == StockLevel.healthy).take(3),
      ...products.where((p) => p.level == StockLevel.low).take(1),
      ...products.where((p) => p.level == StockLevel.out).take(1),
    ];
  }
}

/// One line under the fields: scanner state, or the result of the last scan.
class ScanStatus extends StatelessWidget {
  const ScanStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = PosScope.of(context);
    final feedback = store.scanFeedback;
    final (icon, color) = switch (feedback?.outcome) {
      ScanOutcome.added => (Icons.check_circle_rounded, scheme.primary),
      ScanOutcome.warning => (Icons.warning_amber_rounded, scheme.tertiary),
      ScanOutcome.notFound => (Icons.error_outline_rounded, scheme.error),
      null => (Icons.sensors_rounded, scheme.onSurfaceVariant),
    };
    final message =
        feedback?.message ?? 'Ready. Scanner: ${store.scanner.name}';

    return Semantics(
      liveRegion: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Row(
          key: ValueKey(message),
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: feedback == null ? scheme.onSurfaceVariant : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
