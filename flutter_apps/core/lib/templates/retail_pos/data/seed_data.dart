import 'dart:math';

import '../models/cart.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/store_profile.dart';

const seedStoreProfile = StoreProfile(
  name: 'Fennel Street Market',
  addressLines: ['218 Fennel Street', 'Portland, OR 97205'],
  phone: '(503) 555-0142',
  tillName: 'Till 1',
  taxLabel: 'Sales tax',
  taxRateBasisPoints: 825,
  openingFloatCents: 15000,
);

const seedCategories = [
  ProductCategory(id: 'produce', name: 'Produce'),
  ProductCategory(id: 'bakery', name: 'Bakery'),
  ProductCategory(id: 'dairy', name: 'Dairy'),
  ProductCategory(id: 'pantry', name: 'Pantry'),
  ProductCategory(id: 'drinks', name: 'Drinks'),
  ProductCategory(id: 'home', name: 'Home'),
];

/// Builds a valid EAN-13 from a 12 digit body by adding the check digit.
String ean13(String body) {
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(body[i]) * (i.isEven ? 1 : 3);
  }
  return '$body${(10 - sum % 10) % 10}';
}

Product _item(
  int number,
  String name,
  String categoryId,
  int priceCents,
  int costCents,
  int stock,
  int reorderPoint, {
  bool taxable = false,
}) {
  final code = number.toString().padLeft(4, '0');
  return Product(
    id: 'p$code',
    sku: code,
    barcode: ean13('06204100$code'),
    name: name,
    categoryId: categoryId,
    priceCents: priceCents,
    costCents: costCents,
    stock: stock,
    reorderPoint: reorderPoint,
    taxable: taxable,
  );
}

/// Groceries are tax exempt here, drinks and household goods are not.
final seedProducts = <Product>[
  _item(4011, 'Bananas Bunch', 'produce', 249, 120, 42, 12),
  _item(4131, 'Fuji Apples 1kg', 'produce', 499, 280, 26, 10),
  _item(4065, 'Sweet Peppers', 'produce', 379, 190, 9, 10),
  _item(4593, 'Baby Spinach', 'produce', 429, 230, 18, 8),
  _item(4225, 'Hass Avocado', 'produce', 169, 85, 4, 12),
  _item(4664, 'Vine Tomatoes', 'produce', 449, 240, 31, 10),
  _item(1101, 'Sourdough Loaf', 'bakery', 695, 310, 12, 5),
  _item(1102, 'Butter Croissant', 'bakery', 375, 140, 3, 6),
  _item(1103, 'Seeded Rye', 'bakery', 725, 340, 8, 4),
  _item(1104, 'Cinnamon Bun', 'bakery', 425, 160, 15, 6),
  _item(2201, 'Whole Milk 2L', 'dairy', 459, 290, 34, 12),
  _item(2202, 'Oat Milk 1L', 'dairy', 499, 270, 21, 10),
  _item(2203, 'Salted Butter', 'dairy', 589, 360, 16, 6),
  _item(2204, 'Greek Yogurt', 'dairy', 649, 380, 0, 6),
  _item(2205, 'Aged Cheddar', 'dairy', 899, 540, 11, 5),
  _item(2206, 'Free Range Eggs', 'dairy', 629, 400, 28, 10),
  _item(3301, 'Olive Oil 500ml', 'pantry', 1499, 880, 14, 4),
  _item(3302, 'Basmati Rice 2kg', 'pantry', 1099, 640, 19, 6),
  _item(3303, 'Rigatoni 500g', 'pantry', 329, 150, 47, 12),
  _item(3304, 'Crushed Tomatoes', 'pantry', 279, 120, 38, 12),
  _item(3305, 'Wildflower Honey', 'pantry', 1249, 700, 2, 4),
  _item(3306, 'Sea Salt Crisps', 'pantry', 459, 220, 24, 8),
  _item(5501, 'Cold Brew 330ml', 'drinks', 449, 210, 30, 10, taxable: true),
  _item(5502, 'Sparkling Water', 'drinks', 199, 70, 64, 18, taxable: true),
  _item(5503, 'Ginger Beer 4pk', 'drinks', 899, 480, 13, 5, taxable: true),
  _item(5504, 'Orange Juice 1L', 'drinks', 579, 320, 7, 8, taxable: true),
  _item(5505, 'House Coffee Beans', 'drinks', 1695, 950, 17, 6, taxable: true),
  _item(6601, 'Dish Soap', 'home', 499, 230, 22, 6, taxable: true),
  _item(6602, 'Paper Towels 6pk', 'home', 1299, 780, 10, 4, taxable: true),
  _item(6603, 'Beeswax Candle', 'home', 1450, 620, 6, 3, taxable: true),
  _item(6604, 'Compost Bags', 'home', 749, 350, 25, 6, taxable: true),
];

/// Sales for the last week, oldest first. Uses a fixed random seed so the demo
/// looks the same on every load.
List<SaleDraft> buildSeedHistory(
  List<Product> products,
  DateTime now,
  int taxRateBasisPoints,
) {
  final random = Random(20);
  final today = DateTime(now.year, now.month, now.day);
  final times = <DateTime>[];

  for (var daysAgo = 6; daysAgo >= 1; daysAgo--) {
    final day = today.subtract(Duration(days: daysAgo));
    final count = 14 + random.nextInt(11);
    for (var i = 0; i < count; i++) {
      // Two gaussian-ish humps: late morning and the after-work rush.
      final peak = random.nextBool() ? 11 : 17;
      final hour = peak + random.nextInt(4) - random.nextInt(4);
      times.add(day.add(Duration(hours: hour, minutes: random.nextInt(60))));
    }
  }

  // Today's sales trail back from now, so the summary is never in the future.
  for (var i = 12; i >= 1; i--) {
    final time = now.subtract(Duration(minutes: i * 23 + random.nextInt(12)));
    if (!time.isBefore(today)) times.add(time);
  }
  times.sort();

  return [
    for (final (index, time) in times.indexed)
      _randomSale(index, random, products, time, taxRateBasisPoints),
  ];
}

SaleDraft _randomSale(
  int index,
  Random random,
  List<Product> products,
  DateTime time,
  int taxRateBasisPoints,
) {
  var cart = const Cart();
  final lineCount = 1 + random.nextInt(5);
  for (var i = 0; i < lineCount; i++) {
    final product = products[random.nextInt(products.length)];
    cart = cart.add(product, quantity: 1 + random.nextInt(2));
  }
  if (random.nextInt(9) == 0) {
    cart = cart.setOrderDiscount(const Discount.percent(1000));
  }

  final totals = cart.totals(taxRateBasisPoints);
  final Payment payment;
  if (random.nextInt(10) < 4) {
    final tendered = ((totals.totalCents + 499) ~/ 500) * 500;
    payment = CashPayment(
      tenderedCents: tendered,
      changeCents: tendered - totals.totalCents,
    );
  } else {
    payment = CardPayment(
      brand: random.nextBool() ? 'Visa' : 'Mastercard',
      last4: (1000 + random.nextInt(9000)).toString(),
      authCode: (100000 + random.nextInt(900000)).toString(),
    );
  }
  return SaleDraft.fromCart(
    cart,
    idempotencyKey: 'seed-$index',
    totals: totals,
    payment: payment,
    createdAt: time,
  );
}
