import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../widgets/layout.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';

/// Home, Orders and Cart tabs: a bottom bar on phones, a rail on tablets.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = TabScope.of(context);
    final itemCount = CartScope.of(context).itemCount;
    final activeOrders = OrdersScope.of(context).active.length;

    final body = IndexedStack(
      index: tabs.value,
      children: const [HomeScreen(), OrdersScreen(), CartScreen()],
    );

    Widget cartIcon(IconData icon) => Badge.count(
      count: itemCount,
      isLabelVisible: itemCount > 0,
      child: Icon(icon),
    );

    Widget ordersIcon(IconData icon) =>
        Badge(isLabelVisible: activeOrders > 0, child: Icon(icon));

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= wideBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: tabs.value,
                  onDestinationSelected: (index) => tabs.value = index,
                  groupAlignment: -0.9,
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: ordersIcon(Icons.receipt_long_outlined),
                      selectedIcon: ordersIcon(Icons.receipt_long),
                      label: const Text('Orders'),
                    ),
                    NavigationRailDestination(
                      icon: cartIcon(Icons.shopping_bag_outlined),
                      selectedIcon: cartIcon(Icons.shopping_bag),
                      label: const Text('Cart'),
                    ),
                  ],
                ),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabs.value,
            onDestinationSelected: (index) => tabs.value = index,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Home',
              ),
              NavigationDestination(
                icon: ordersIcon(Icons.receipt_long_outlined),
                selectedIcon: ordersIcon(Icons.receipt_long),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: cartIcon(Icons.shopping_bag_outlined),
                selectedIcon: cartIcon(Icons.shopping_bag),
                label: 'Cart',
              ),
            ],
          ),
        );
      },
    );
  }
}
