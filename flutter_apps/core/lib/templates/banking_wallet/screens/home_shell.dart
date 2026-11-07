import 'package:flutter/material.dart';

import '../state/wallet_controller.dart';
import '../state/wallet_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/wallet_theme.dart';
import 'activity_screen.dart';
import 'cards_screen.dart';
import 'insights_screen.dart';
import 'overview_screen.dart';
import 'send/recipient_screen.dart';

/// The signed-in app: four tabs behind a bottom bar on phones and a rail on
/// tablets. Tabs stay alive in an [IndexedStack], so a search typed in
/// Activity is still there after a detour through Cards.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _destinations = [
    (
      label: 'Home',
      icon: Icons.account_balance_wallet_outlined,
      selected: Icons.account_balance_wallet,
    ),
    (
      label: 'Activity',
      icon: Icons.receipt_long_outlined,
      selected: Icons.receipt_long,
    ),
    (
      label: 'Cards',
      icon: Icons.credit_card_outlined,
      selected: Icons.credit_card,
    ),
    (
      label: 'Insights',
      icon: Icons.bar_chart_outlined,
      selected: Icons.bar_chart,
    ),
  ];

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  void _openSend() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RecipientScreen()));
  }

  Widget _buildBody(WalletController wallet) {
    switch (wallet.status) {
      case WalletLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WalletLoadStatus.failed:
        return EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load your accounts',
          message: 'Check your connection and try again.',
          actionLabel: 'Try again',
          onAction: wallet.load,
        );
      case WalletLoadStatus.ready:
        return IndexedStack(
          index: _index,
          children: [
            OverviewScreen(
              onSeeAllActivity: () => _select(1),
              onOpenSend: _openSend,
            ),
            const ActivityScreen(),
            const CardsScreen(),
            const InsightsScreen(),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);
    final useRail = MediaQuery.sizeOf(context).width >= railBreakpoint;
    final body = SafeArea(child: _buildBody(wallet));

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: FloatingActionButton(
                  tooltip: 'Send money',
                  elevation: 0,
                  onPressed: _openSend,
                  child: const Icon(Icons.north_east),
                ),
              ),
              destinations: [
                for (final item in _destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selected),
                    label: Text(item.label),
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
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selected),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
