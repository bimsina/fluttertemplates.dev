import 'package:flutter/material.dart';

import '../state/pos_scope.dart';
import '../widgets/stale_data_notice.dart';
import 'inventory_screen.dart';
import 'register_screen.dart';
import 'sales_screen.dart';

/// Top-level navigation: a rail on tablets, a bottom bar on phones. Tabs stay
/// alive in an [IndexedStack], so a half-built sale survives a stock check.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const _railBreakpoint = 720.0;

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);

    if (store.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (store.loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The store data could not be loaded.'),
              const SizedBox(height: 12),
              FilledButton(onPressed: store.load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final alertCount = store.alerts.length;
    final inventoryIcon = Badge(
      isLabelVisible: alertCount > 0,
      label: Text('$alertCount'),
      child: const Icon(Icons.inventory_2_outlined),
    );
    final inventorySelected = Badge(
      isLabelVisible: alertCount > 0,
      label: Text('$alertCount'),
      child: const Icon(Icons.inventory_2_rounded),
    );

    // With large text on a small screen the notice can outgrow the page, so it
    // scrolls within a share of the height and the page stays usable.
    final pages = LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.4),
            child: const SingleChildScrollView(
              child: StaleDataNotice(margin: EdgeInsets.fromLTRB(12, 8, 12, 0)),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                RegisterScreen(),
                InventoryScreen(),
                SalesScreen(),
              ],
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  leading: const _StoreMark(),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.point_of_sale_outlined),
                      selectedIcon: Icon(Icons.point_of_sale_rounded),
                      label: Text('Register'),
                    ),
                    NavigationRailDestination(
                      icon: inventoryIcon,
                      selectedIcon: inventorySelected,
                      label: const Text('Inventory'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_rounded),
                      label: Text('Sales'),
                    ),
                  ],
                ),
                Expanded(child: pages),
              ],
            ),
          );
        }
        return Scaffold(
          body: SafeArea(bottom: false, child: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.point_of_sale_outlined),
                selectedIcon: Icon(Icons.point_of_sale_rounded),
                label: 'Register',
              ),
              NavigationDestination(
                icon: inventoryIcon,
                selectedIcon: inventorySelected,
                label: 'Inventory',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Sales',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreMark extends StatelessWidget {
  const _StoreMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(top: 4, bottom: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.storefront_rounded,
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
    );
  }
}
