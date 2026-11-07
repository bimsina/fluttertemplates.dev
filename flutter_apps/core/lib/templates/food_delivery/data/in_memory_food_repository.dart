import 'dart:async';

import '../models/cart_line.dart';
import '../models/order.dart';
import '../models/restaurant.dart';
import 'fake_data.dart';
import 'food_repository.dart';

/// Fake backend: fixed data, a short delay on each call, and a simulated
/// courier. Replace it with an API client that implements [FoodRepository].
class InMemoryFoodRepository implements FoodRepository {
  InMemoryFoodRepository({
    this.latency = const Duration(milliseconds: 450),
    this.deliveryDuration = const Duration(seconds: 45),
  });

  final Duration latency;

  /// How long the simulated delivery takes from placed to delivered.
  final Duration deliveryDuration;

  static const _tick = Duration(milliseconds: 250);
  static const _couriers = ['Maya', 'Tomas', 'Aisha', 'Leo'];

  int _nextOrderNumber = 4821;

  @override
  Future<List<FoodCategory>> fetchCategories() async {
    await Future<void>.delayed(latency);
    return fakeCategories;
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    await Future<void>.delayed(latency);
    return fakeRestaurants;
  }

  @override
  Future<List<Order>> fetchOrders() async {
    await Future<void>.delayed(latency);
    return _pastOrders();
  }

  @override
  Future<PromoCode?> redeemPromo(String code) async {
    await Future<void>.delayed(latency);
    return fakePromoCodes[code.trim().toUpperCase()];
  }

  @override
  Future<Order> placeOrder(OrderDraft draft) async {
    await Future<void>.delayed(latency * 2);
    final number = _nextOrderNumber++;
    return Order(
      id: 'FD-$number',
      restaurant: draft.restaurant,
      lines: draft.lines,
      prices: draft.prices,
      address: draft.address,
      payment: draft.payment,
      placedAt: DateTime.now(),
      status: OrderStatus.confirmed,
      progress: 0,
      courierName: _couriers[number % _couriers.length],
      scheduledFor: draft.scheduledFor,
    );
  }

  @override
  Stream<TrackingUpdate> watchOrder(String orderId) async* {
    final ticks = deliveryDuration.inMilliseconds ~/ _tick.inMilliseconds;
    for (var i = 1; i <= ticks; i++) {
      await Future<void>.delayed(_tick);
      final progress = i / ticks;
      yield TrackingUpdate(status: _statusAt(progress), progress: progress);
    }
  }

  OrderStatus _statusAt(double progress) {
    if (progress >= 1) return OrderStatus.delivered;
    if (progress >= 0.4) return OrderStatus.onTheWay;
    if (progress >= 0.12) return OrderStatus.preparing;
    return OrderStatus.confirmed;
  }

  List<Order> _pastOrders() {
    const address = DeliveryAddress(
      street: '18 Orchard Lane',
      unit: 'Apt 4B',
      phone: '5550142',
      instructions: '',
    );

    Order past({
      required String id,
      required int restaurantIndex,
      required int daysAgo,
      required List<int> itemIndexes,
    }) {
      final restaurant = fakeRestaurants[restaurantIndex];
      final items = restaurant.sections.expand((s) => s.items).toList();
      final lines = [
        for (final index in itemIndexes)
          CartLine(
            id: '$id-$index',
            item: items[index],
            // The first option of each required group, as a customer would
            // have picked one.
            selected: [
              for (final group in items[index].optionGroups)
                if (group.isRequired) group.options.first,
            ],
            quantity: 1,
          ),
      ];
      final subtotal = lines.fold(0, (sum, line) => sum + line.totalCents);
      return Order(
        id: id,
        restaurant: restaurant,
        lines: lines,
        prices: PriceBreakdown(
          subtotalCents: subtotal,
          deliveryFeeCents: restaurant.deliveryFeeCents,
          serviceFeeCents: (subtotal * 0.05).round(),
          taxCents: (subtotal * 0.08).round(),
          discountCents: 0,
          tipCents: (subtotal * 0.15).round(),
        ),
        address: address,
        payment: PaymentType.card,
        placedAt: DateTime.now().subtract(Duration(days: daysAgo, hours: 3)),
        status: OrderStatus.delivered,
        progress: 1,
        courierName: _couriers[daysAgo % _couriers.length],
      );
    }

    return [
      past(id: 'FD-4807', restaurantIndex: 1, daysAgo: 2, itemIndexes: [0, 3]),
      past(id: 'FD-4762', restaurantIndex: 0, daysAgo: 6, itemIndexes: [0, 1]),
      past(id: 'FD-4698', restaurantIndex: 4, daysAgo: 13, itemIndexes: [1]),
    ];
  }
}
