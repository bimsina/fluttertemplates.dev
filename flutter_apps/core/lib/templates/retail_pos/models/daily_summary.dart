import 'format.dart';
import 'sale.dart';

class TopProduct {
  const TopProduct({
    required this.name,
    required this.units,
    required this.netCents,
  });

  final String name;
  final int units;

  /// After line discounts, before order discounts and tax.
  final int netCents;
}

/// Takings for one calendar day, computed from that day's sales.
class DailySummary {
  DailySummary._({
    required this.day,
    required this.sales,
    required this.grossCents,
    required this.discountCents,
    required this.taxCents,
    required this.cashCents,
    required this.cardCents,
    required this.unitsSold,
    required this.hourlyCents,
    required this.topProducts,
  });

  factory DailySummary.forDay(DateTime day, Iterable<Sale> allSales) {
    final sales =
        allSales.where((sale) => isSameDay(sale.createdAt, day)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    var gross = 0;
    var discount = 0;
    var tax = 0;
    var cash = 0;
    var card = 0;
    var units = 0;
    final hourly = List<int>.filled(24, 0);
    final byName = <String, ({int units, int net})>{};

    for (final sale in sales) {
      gross += sale.totals.grossCents;
      discount += sale.totals.discountCents;
      tax += sale.totals.taxCents;
      units += sale.itemCount;
      hourly[sale.createdAt.hour] += sale.totals.totalCents;
      switch (sale.payment) {
        case CashPayment():
          cash += sale.totals.totalCents;
        case CardPayment():
          card += sale.totals.totalCents;
      }
      for (final line in sale.lines) {
        final current = byName[line.name] ?? (units: 0, net: 0);
        byName[line.name] = (
          units: current.units + line.quantity,
          net: current.net + line.netCents,
        );
      }
    }

    final top =
        byName.entries
            .map(
              (entry) => TopProduct(
                name: entry.key,
                units: entry.value.units,
                netCents: entry.value.net,
              ),
            )
            .toList()
          ..sort((a, b) => b.netCents.compareTo(a.netCents));

    return DailySummary._(
      day: startOfDay(day),
      sales: sales,
      grossCents: gross,
      discountCents: discount,
      taxCents: tax,
      cashCents: cash,
      cardCents: card,
      unitsSold: units,
      hourlyCents: hourly,
      topProducts: top.take(5).toList(growable: false),
    );
  }

  final DateTime day;

  /// Newest first.
  final List<Sale> sales;
  final int grossCents;
  final int discountCents;
  final int taxCents;
  final int cashCents;
  final int cardCents;
  final int unitsSold;

  /// 24 entries, takings per hour of the day.
  final List<int> hourlyCents;
  final List<TopProduct> topProducts;

  int get saleCount => sales.length;
  int get netSalesCents => grossCents - discountCents;
  int get takingsCents => cashCents + cardCents;
  int get averageSaleCents => saleCount == 0 ? 0 : takingsCents ~/ saleCount;
}
