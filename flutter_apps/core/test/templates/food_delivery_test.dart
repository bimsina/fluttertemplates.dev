import 'dart:async';

import 'package:core/templates/food_delivery/data/fake_data.dart';
import 'package:core/templates/food_delivery/data/in_memory_food_repository.dart';
import 'package:core/templates/food_delivery/models/order.dart';
import 'package:core/templates/food_delivery/screens/orders_screen.dart';
import 'package:core/templates/food_delivery/screens/tracking_screen.dart';
import 'package:core/templates/food_delivery/state/app_scope.dart';
import 'package:core/templates/food_delivery/state/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hands the test each tracking stream, so it can fail or close them.
class ScriptedTrackingRepository extends InMemoryFoodRepository {
  ScriptedTrackingRepository() : super(latency: Duration.zero);

  final streams = <StreamController<TrackingUpdate>>[];
  bool throwOnWatch = false;
  bool failOrders = false;

  StreamController<TrackingUpdate> get latest => streams.last;

  @override
  Future<List<Order>> fetchOrders() {
    if (failOrders) return Future.error(StateError('orders offline'));
    return super.fetchOrders();
  }

  @override
  Stream<TrackingUpdate> watchOrder(String orderId) {
    if (throwOnWatch) throw StateError('tracking offline');
    final controller = StreamController<TrackingUpdate>();
    streams.add(controller);
    return controller.stream;
  }
}

final draft = OrderDraft(
  restaurant: fakeRestaurants.first,
  lines: const [],
  prices: PriceBreakdown.empty,
  address: const DeliveryAddress(
    street: '1 Test Street',
    unit: '',
    phone: '5550100',
    instructions: '',
  ),
  payment: PaymentType.cash,
  scheduledFor: null,
);

const onTheWay = TrackingUpdate(status: OrderStatus.onTheWay, progress: 0.5);
const delivered = TrackingUpdate(status: OrderStatus.delivered, progress: 1);

Future<(OrdersController, ScriptedTrackingRepository, Order)> placed() async {
  final repository = ScriptedTrackingRepository();
  final orders = OrdersController(repository);
  addTearDown(orders.dispose);
  final order = await orders.place(draft);
  await pumpEventQueue();
  return (orders, repository, order);
}

void main() {
  group('tracking errors', () {
    test('are caught, flagged, and keep the last known status', () async {
      final (orders, repository, order) = await placed();
      repository.latest.add(onTheWay);
      await pumpEventQueue();

      repository.latest.addError(StateError('tracking offline'));
      await pumpEventQueue();

      expect(orders.hasError, isTrue);
      expect(orders.hasTrackingError(order.id), isTrue);
      expect(orders.hasLoadError, isFalse);
      expect(orders.byId(order.id)!.status, OrderStatus.onTheWay);
      expect(orders.byId(order.id)!.progress, 0.5);
    });

    test('clear if the same stream recovers', () async {
      final (orders, repository, order) = await placed();
      repository.latest.addError(StateError('blip'));
      await pumpEventQueue();

      repository.latest.add(onTheWay);
      await pumpEventQueue();

      expect(orders.hasError, isFalse);
      expect(orders.byId(order.id)!.progress, 0.5);
    });

    test('retry listens again and picks up updates', () async {
      final (orders, repository, order) = await placed();
      final first = repository.latest;
      first.addError(StateError('tracking offline'));
      await pumpEventQueue();

      orders.retryTracking(order.id);
      await pumpEventQueue();

      expect(repository.streams, hasLength(2));
      expect(first.hasListener, isFalse);
      expect(orders.hasError, isFalse);
      repository.latest.add(onTheWay);
      await pumpEventQueue();
      expect(orders.byId(order.id)!.progress, 0.5);
    });

    test('load retries failed tracking too', () async {
      final (orders, repository, order) = await placed();
      repository.latest.addError(StateError('tracking offline'));
      await pumpEventQueue();

      await orders.load();

      expect(repository.streams, hasLength(2));
      expect(orders.hasTrackingError(order.id), isFalse);
    });

    test('a stream that closes early counts as a failure', () async {
      final (orders, repository, order) = await placed();

      await repository.latest.close();
      await pumpEventQueue();

      expect(orders.hasTrackingError(order.id), isTrue);
    });

    test('a stream that closes after delivery is not a failure', () async {
      final (orders, repository, order) = await placed();

      repository.latest.add(delivered);
      await repository.latest.close();
      await pumpEventQueue();

      expect(orders.hasError, isFalse);
      expect(orders.byId(order.id)!.isActive, isFalse);
    });

    test('a watch that throws can\'t fail an order that was placed', () async {
      final repository = ScriptedTrackingRepository()..throwOnWatch = true;
      final orders = OrdersController(repository);
      addTearDown(orders.dispose);

      final order = await orders.place(draft);

      expect(orders.byId(order.id), isNotNull);
      expect(orders.hasTrackingError(order.id), isTrue);
    });

    test('a history failure stays separate from tracking', () async {
      final repository = ScriptedTrackingRepository()..failOrders = true;
      final orders = OrdersController(repository);
      addTearDown(orders.dispose);
      await pumpEventQueue();

      expect(orders.hasLoadError, isTrue);
      expect(orders.hasError, isTrue);

      repository.failOrders = false;
      await orders.load();
      expect(orders.hasError, isFalse);
    });
  });

  group('screens', () {
    Future<(OrdersController, ScriptedTrackingRepository, Order)> mount(
      WidgetTester tester,
      Widget Function(Order order) screen,
    ) async {
      tester.view.physicalSize = const Size(1100, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = ScriptedTrackingRepository();
      final tabs = ValueNotifier<int>(TabScope.orders);
      // The controller loads history as it is created, on real timers.
      final (orders, order) = (await tester.runAsync(() async {
        final orders = OrdersController(repository);
        final order = await orders.place(draft);
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return (orders, order);
      }))!;
      await tester.pumpWidget(
        MaterialApp(
          home: OrdersScope(
            controller: orders,
            child: TabScope(controller: tabs, child: screen(order)),
          ),
        ),
      );
      await tester.pump();
      return (orders, repository, order);
    }

    Future<void> unmount(WidgetTester tester, OrdersController orders) async {
      await tester.pumpWidget(const SizedBox());
      orders.dispose();
    }

    testWidgets('tracking shows the failure and retry clears it', (
      tester,
    ) async {
      final (orders, repository, order) = await mount(
        tester,
        (order) => TrackingScreen(orderId: order.id),
      );
      expect(find.textContaining('Live tracking stopped'), findsNothing);

      repository.latest.addError(StateError('tracking offline'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Live tracking stopped'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Live tracking stopped'), findsNothing);
      expect(repository.streams, hasLength(2));
      await unmount(tester, orders);
    });

    testWidgets('the orders list shows the failure beside the order', (
      tester,
    ) async {
      final (orders, repository, _) = await mount(
        tester,
        (_) => const OrdersScreen(),
      );

      repository.latest.addError(StateError('tracking offline'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Live tracking stopped'), findsOneWidget);
      expect(find.text('Could not load your orders'), findsNothing);
      await unmount(tester, orders);
    });
  });
}
