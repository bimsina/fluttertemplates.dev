import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/food_repository.dart';
import '../models/order.dart';

/// Order history plus live tracking. Subscriptions live here rather than in a
/// screen, so a delivery keeps moving while the customer browses elsewhere.
class OrdersController extends ChangeNotifier {
  OrdersController(this._repository) {
    load();
  }

  final FoodRepository _repository;
  final Map<String, StreamSubscription<TrackingUpdate>> _tracking = {};

  /// Orders whose tracking stream failed, until it emits again.
  final Set<String> _trackingFailures = {};

  List<Order> _orders = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  /// True when order history failed to load or any order lost its tracking.
  bool get hasError => _hasLoadError || _trackingFailures.isNotEmpty;

  /// True when order history failed to load. [load] retries it.
  bool get hasLoadError => _hasLoadError;

  /// True when this order's live status has stopped updating. The order keeps
  /// its last known status. [retryTracking] listens again.
  bool hasTrackingError(String orderId) => _trackingFailures.contains(orderId);

  List<Order> get active => _orders.where((o) => o.isActive).toList();
  List<Order> get past => _orders.where((o) => !o.isActive).toList();

  Order? byId(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _hasLoadError = false;
    notifyListeners();
    _trackingFailures.toList().forEach(retryTracking);
    try {
      final history = await _repository.fetchOrders();
      if (_disposed) return;
      final known = _orders.map((o) => o.id).toSet();
      _orders = [..._orders, ...history.where((o) => !known.contains(o.id))];
    } catch (_) {
      if (_disposed) return;
      _hasLoadError = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Order> place(OrderDraft draft) async {
    final order = await _repository.placeOrder(draft);
    if (_disposed) return order;
    _orders = [order, ..._orders];
    _track(order.id);
    notifyListeners();
    return order;
  }

  /// Listens to a failed order's tracking again.
  void retryTracking(String orderId) {
    if (_trackingFailures.remove(orderId)) notifyListeners();
    _track(orderId);
  }

  // The order exists once this is called, so tracking trouble is reported on
  // the order and never thrown back at whoever placed it.
  void _track(String orderId) {
    _tracking.remove(orderId)?.cancel();
    try {
      _tracking[orderId] = _repository
          .watchOrder(orderId)
          .listen(
            (update) => _onTrackingUpdate(orderId, update),
            onError: (Object error, StackTrace stackTrace) {
              _onTrackingFailed(orderId, error, stackTrace);
            },
            onDone: () => _onTrackingDone(orderId),
          );
    } catch (error, stackTrace) {
      _onTrackingFailed(orderId, error, stackTrace);
    }
  }

  void _onTrackingUpdate(String orderId, TrackingUpdate update) {
    _trackingFailures.remove(orderId);
    _orders = [
      for (final order in _orders)
        order.id == orderId
            ? order.copyWith(status: update.status, progress: update.progress)
            : order,
    ];
    notifyListeners();
  }

  void _onTrackingFailed(String orderId, Object error, StackTrace stackTrace) {
    debugPrint('Tracking failed for $orderId: $error\n$stackTrace');
    if (_disposed) return;
    _trackingFailures.add(orderId);
    notifyListeners();
  }

  /// The stream only closes by itself after the delivered event, so closing
  /// on an active order means the updates have stopped.
  void _onTrackingDone(String orderId) {
    _tracking.remove(orderId);
    if (_disposed || !(byId(orderId)?.isActive ?? false)) return;
    _trackingFailures.add(orderId);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _tracking.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}
