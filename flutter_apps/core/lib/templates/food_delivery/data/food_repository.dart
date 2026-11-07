import '../models/order.dart';
import '../models/restaurant.dart';

/// Everything the app needs from a backend.
///
/// The UI and controllers only know about this interface. To connect a real
/// API, implement it and return it from `createDefaultRepository()` in
/// `default_repository.dart`.
abstract class FoodRepository {
  Future<List<FoodCategory>> fetchCategories();

  Future<List<Restaurant>> fetchRestaurants();

  /// Past and in-progress orders for the signed in customer, newest first.
  Future<List<Order>> fetchOrders();

  /// Returns null when the code is not valid.
  Future<PromoCode?> redeemPromo(String code);

  Future<Order> placeOrder(OrderDraft draft);

  /// Live status for one order. Closes after the delivered event.
  ///
  /// An error, or closing any earlier, shows the customer that tracking
  /// stopped, with a retry that calls this again. So the first event after a
  /// new listen should be the order's current status.
  Stream<TrackingUpdate> watchOrder(String orderId);
}
