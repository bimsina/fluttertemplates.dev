import 'package:flutter/widgets.dart';

import '../data/food_repository.dart';
import 'cart_controller.dart';
import 'orders_controller.dart';

/// Makes the cart available below the app root. Widgets that call [of]
/// rebuild when the cart changes.
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartScope>()!.notifier!;

  /// For callbacks: reads the cart without subscribing to changes.
  static CartController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CartScope>()!.notifier!;
}

/// Same as [CartScope], for orders. Kept separate because tracking ticks
/// several times a second and must not rebuild cart widgets.
class OrdersScope extends InheritedNotifier<OrdersController> {
  const OrdersScope({
    super.key,
    required OrdersController controller,
    required super.child,
  }) : super(notifier: controller);

  static OrdersController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OrdersScope>()!.notifier!;

  static OrdersController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OrdersScope>()!.notifier!;
}

/// The selected bottom navigation tab, so any screen can jump to a tab.
class TabScope extends InheritedNotifier<ValueNotifier<int>> {
  const TabScope({
    super.key,
    required ValueNotifier<int> controller,
    required super.child,
  }) : super(notifier: controller);

  static const home = 0;
  static const orders = 1;
  static const cart = 2;

  static ValueNotifier<int> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabScope>()!.notifier!;

  static ValueNotifier<int> read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TabScope>()!.notifier!;
}

/// Hands the repository to screens that load their own data.
class RepositoryScope extends InheritedWidget {
  const RepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final FoodRepository repository;

  static FoodRepository of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<RepositoryScope>()!.repository;

  @override
  bool updateShouldNotify(RepositoryScope oldWidget) =>
      repository != oldWidget.repository;
}
