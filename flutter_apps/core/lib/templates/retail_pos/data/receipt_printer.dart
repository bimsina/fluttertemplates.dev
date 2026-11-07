import '../models/format.dart';
import '../models/sale.dart';
import '../models/store_profile.dart';

class PrintResult {
  const PrintResult({required this.message});

  /// Shown to the cashier after printing.
  final String message;
}

/// Replace with a driver for your printer and pass it to
/// `RetailPosApp(receiptPrinter: ...)`. Most thermal printers accept the output
/// of [formatReceipt] wrapped in ESC/POS commands.
abstract interface class ReceiptPrinter {
  Future<PrintResult> printReceipt(Sale sale, StoreProfile store);
}

/// No device attached. Formats the receipt and keeps the text in [lastOutput].
class PreviewReceiptPrinter implements ReceiptPrinter {
  String? lastOutput;

  @override
  Future<PrintResult> printReceipt(Sale sale, StoreProfile store) async {
    final lines = formatReceipt(sale, store);
    lastOutput = lines.join('\n');
    return PrintResult(
      message: 'No printer attached. ${lines.length} lines formatted.',
    );
  }
}

/// Lays a sale out as fixed-width text for an 80mm thermal printer.
List<String> formatReceipt(Sale sale, StoreProfile store, {int width = 42}) {
  String center(String text) =>
      text.padLeft((width + text.length) ~/ 2).padRight(width);
  String row(String left, String right) {
    final room = width - right.length - 1;
    final clipped = left.length > room ? left.substring(0, room) : left;
    return '${clipped.padRight(room)} $right';
  }

  final totals = sale.totals;
  final payment = sale.payment;
  return [
    center(store.name),
    ...store.addressLines.map(center),
    center(store.phone),
    '',
    row(sale.receiptNumber, store.tillName),
    formatDateTime(sale.createdAt),
    '-' * width,
    for (final line in sale.lines) ...[
      row(line.name, formatMoney(line.unitPriceCents * line.quantity)),
      if (line.quantity > 1)
        '  ${line.quantity} x ${formatMoney(line.unitPriceCents)}',
      if (line.discountCents > 0)
        row(
          '  ${line.discountLabel ?? 'Discount'}',
          formatMoney(-line.discountCents),
        ),
    ],
    '-' * width,
    row('Subtotal', formatMoney(totals.grossCents)),
    if (totals.orderDiscountCents > 0)
      row(
        'Order ${sale.orderDiscountLabel ?? 'discount'}',
        formatMoney(-totals.orderDiscountCents),
      ),
    row(store.taxLabel, formatMoney(totals.taxCents)),
    row('TOTAL', formatMoney(totals.totalCents)),
    '',
    ...switch (payment) {
      CashPayment(:final tenderedCents, :final changeCents) => [
        row('Cash', formatMoney(tenderedCents)),
        row('Change', formatMoney(changeCents)),
      ],
      CardPayment(:final brand, :final last4, :final authCode) => [
        row('$brand **** $last4', formatMoney(totals.totalCents)),
        row('Auth code', authCode),
      ],
    },
    '',
    center('Thank you'),
  ];
}
