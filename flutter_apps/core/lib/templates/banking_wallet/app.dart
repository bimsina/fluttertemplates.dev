import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'data/default_repository.dart';
import 'data/wallet_repository.dart';
import 'screens/home_shell.dart';
import 'screens/lock_screen.dart';
import 'state/wallet_controller.dart';
import 'state/wallet_scope.dart';
import 'widgets/wallet_theme.dart';

/// A personal banking app: PIN lock, accounts, transactions, transfers, cards
/// and spending insights.
///
/// Drop it anywhere under a `MaterialApp`. It follows the brightness of the
/// surrounding theme, and owns its state and navigation.
///
/// ```dart
/// MaterialApp(home: const BankingWalletApp());
/// ```
class BankingWalletApp extends StatefulWidget {
  const BankingWalletApp({
    super.key,
    this.repository,
    this.seedColor = defaultSeedColor,
  });

  /// Where data comes from. Defaults to `createDefaultRepository()` in
  /// `data/default_repository.dart`, which is the place to connect a real
  /// backend. Passing one here overrides it, for example in tests.
  final WalletRepository? repository;

  /// The color the app's whole color scheme is generated from.
  final Color seedColor;

  @override
  State<BankingWalletApp> createState() => _BankingWalletAppState();
}

class _BankingWalletAppState extends State<BankingWalletApp> {
  late final WalletController _controller = WalletController(
    widget.repository ?? createDefaultRepository(),
  )..load();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWalletTheme(
        seedColor: widget.seedColor,
        brightness: Theme.of(context).brightness,
      ),
      child: ScrollConfiguration(
        // Browsers don't drag-scroll with a mouse by default, which would
        // leave the card carousel and chip rows stuck on desktop.
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
          },
        ),
        child: WalletScope(
          controller: _controller,
          child: const ScaffoldMessenger(child: _WalletNavigator()),
        ),
      ),
    );
  }
}

/// The nested navigator. Its one page follows the lock state, so locking
/// discards whatever was open on top of the home screen.
class _WalletNavigator extends StatefulWidget {
  const _WalletNavigator();

  @override
  State<_WalletNavigator> createState() => _WalletNavigatorState();
}

class _WalletNavigatorState extends State<_WalletNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final isUnlocked = WalletScope.of(context).isUnlocked;
    // Forwards the system back button to this navigator rather than the
    // app's root navigator.
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        pages: [
          if (isUnlocked)
            const _FadePage(key: ValueKey('home'), child: HomeShell())
          else
            const _FadePage(key: ValueKey('lock'), child: LockScreen()),
        ],
        onDidRemovePage: (_) {},
      ),
    );
  }
}

class _FadePage extends Page<void> {
  const _FadePage({required super.key, required this.child});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
