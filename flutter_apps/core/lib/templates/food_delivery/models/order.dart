import 'cart_line.dart';
import 'restaurant.dart';

enum OrderStatus {
  confirmed('Order confirmed', 'The restaurant has your order'),
  preparing('Preparing your food', 'The kitchen is on it'),
  onTheWay('On the way', 'Your courier has picked up the order'),
  delivered('Delivered', 'Enjoy your meal');

  const OrderStatus(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

enum PaymentType {
  card('Credit or debit card'),
  wallet('Digital wallet'),
  cash('Cash on delivery');

  const PaymentType(this.label);

  final String label;
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.street,
    required this.unit,
    required this.phone,
    required this.instructions,
  });

  final String street;
  final String unit;
  final String phone;
  final String instructions;

  String get singleLine => unit.isEmpty ? street : '$street, $unit';
}

class PromoCode {
  const PromoCode({
    required this.code,
    required this.label,
    this.percentOff = 0,
    this.freeDelivery = false,
  });

  final String code;
  final String label;
  final int percentOff;
  final bool freeDelivery;
}

/// All money in the app is integer cents, so totals never drift.
class PriceBreakdown {
  const PriceBreakdown({
    required this.subtotalCents,
    required this.deliveryFeeCents,
    required this.serviceFeeCents,
    required this.taxCents,
    required this.discountCents,
    required this.tipCents,
  });

  static const empty = PriceBreakdown(
    subtotalCents: 0,
    deliveryFeeCents: 0,
    serviceFeeCents: 0,
    taxCents: 0,
    discountCents: 0,
    tipCents: 0,
  );

  final int subtotalCents;
  final int deliveryFeeCents;
  final int serviceFeeCents;
  final int taxCents;
  final int discountCents;
  final int tipCents;

  int get totalCents =>
      subtotalCents +
      deliveryFeeCents +
      serviceFeeCents +
      taxCents +
      tipCents -
      discountCents;
}

/// What the app sends to the backend when the customer places an order.
class OrderDraft {
  const OrderDraft({
    required this.restaurant,
    required this.lines,
    required this.prices,
    required this.address,
    required this.payment,
    required this.scheduledFor,
  });

  final Restaurant restaurant;
  final List<CartLine> lines;
  final PriceBreakdown prices;
  final DeliveryAddress address;
  final PaymentType payment;

  /// Null means as soon as possible.
  final String? scheduledFor;
}

class Order {
  const Order({
    required this.id,
    required this.restaurant,
    required this.lines,
    required this.prices,
    required this.address,
    required this.payment,
    required this.placedAt,
    required this.status,
    required this.progress,
    required this.courierName,
    this.scheduledFor,
  });

  final String id;
  final Restaurant restaurant;
  final List<CartLine> lines;
  final PriceBreakdown prices;
  final DeliveryAddress address;
  final PaymentType payment;
  final DateTime placedAt;
  final OrderStatus status;

  /// 0 when placed, 1 when delivered. Drives the tracking map.
  final double progress;
  final String courierName;
  final String? scheduledFor;

  bool get isActive => status != OrderStatus.delivered;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  int get minutesRemaining => ((1 - progress) * restaurant.etaMinutes).ceil();

  Order copyWith({OrderStatus? status, double? progress}) => Order(
    id: id,
    restaurant: restaurant,
    lines: lines,
    prices: prices,
    address: address,
    payment: payment,
    placedAt: placedAt,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    courierName: courierName,
    scheduledFor: scheduledFor,
  );
}

/// One live event from the backend for an order in progress.
class TrackingUpdate {
  const TrackingUpdate({required this.status, required this.progress});

  final OrderStatus status;
  final double progress;
}
