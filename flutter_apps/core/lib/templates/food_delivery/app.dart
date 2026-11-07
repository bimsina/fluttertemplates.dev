import 'package:flutter/material.dart';

import 'data/default_repository.dart';
import 'data/food_repository.dart';
import 'screens/shell_screen.dart';
import 'state/app_scope.dart';
import 'state/cart_controller.dart';
import 'state/orders_controller.dart';
import 'widgets/food_theme.dart';

/// Root of the food delivery template.
///
/// Drop it anywhere under a MaterialApp. It follows the brightness of the
/// surrounding theme and keeps its own navigation stack, so it can fill a
/// whole app or a single tab.
class FoodDeliveryApp extends StatefulWidget {
  const FoodDeliveryApp({
    super.key,
    this.repository,
    this.seedColor = brandSeed,
  });

  /// The data source. Defaults to `createDefaultRepository()` in
  /// `data/default_repository.dart`, which is the place to connect a real
  /// backend. Passing one here overrides it, for example in tests.
  final FoodRepository? repository;

  /// Seed for the screens that do not belong to a restaurant.
  final Color seedColor;

  @override
  State<FoodDeliveryApp> createState() => _FoodDeliveryAppState();
}

class _FoodDeliveryAppState extends State<FoodDeliveryApp> {
  late final FoodRepository _repository =
      widget.repository ?? createDefaultRepository();
  late final OrdersController _orders = OrdersController(_repository);
  final _cart = CartController();
  final _tabs = ValueNotifier<int>(TabScope.home);
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _heroController = MaterialApp.createMaterialHeroController();

  @override
  void dispose() {
    _orders.dispose();
    _cart.dispose();
    _tabs.dispose();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FoodTheme(
      seed: widget.seedColor,
      variant: DynamicSchemeVariant.tonalSpot,
      child: RepositoryScope(
        repository: _repository,
        child: CartScope(
          controller: _cart,
          child: OrdersScope(
            controller: _orders,
            child: TabScope(
              controller: _tabs,
              child: ScaffoldMessenger(
                // Sends system back to the nested navigator first.
                child: NavigatorPopHandler(
                  onPopWithResult: (_) =>
                      _navigatorKey.currentState?.maybePop(),
                  child: HeroControllerScope(
                    controller: _heroController,
                    child: Navigator(
                      key: _navigatorKey,
                      onGenerateRoute: (settings) => MaterialPageRoute<void>(
                        settings: settings,
                        builder: (_) => const ShellScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
