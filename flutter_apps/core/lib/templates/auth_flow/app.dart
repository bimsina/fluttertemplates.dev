import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'data/auth_demo_controls.dart';
import 'data/auth_repository.dart';
import 'data/default_repository.dart';
import 'screens/change_password_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/verify_email_screen.dart';
import 'state/appearance_controller.dart';
import 'state/auth_controller.dart';
import 'state/auth_navigation.dart';
import 'state/auth_scope.dart';
import 'widgets/auth_theme.dart';
import 'widgets/notice_strip.dart';

/// A connected auth starter: session restore, sign in, sign up, email
/// verification, password recovery, and account settings.
///
/// Drop it anywhere under a `MaterialApp`. It owns its state and navigation.
///
/// ```dart
/// MaterialApp(home: const AuthFlowApp());
/// ```
class AuthFlowApp extends StatefulWidget {
  const AuthFlowApp({
    super.key,
    this.repository,
    this.seedColor = defaultAuthSeed,
    this.appName = 'Latchkey',
  });

  /// Defaults to `createDefaultRepository()` in
  /// `data/default_repository.dart`, which is the SWAP POINT for connecting a
  /// real backend. Passing one here overrides it, for example in tests. A
  /// repository you pass in stays yours to dispose. It is read once, when this
  /// widget is first built.
  final AuthRepository? repository;

  /// The color the whole color scheme is generated from.
  final Color seedColor;

  /// Shown on the splash screen and form headers.
  final String appName;

  @override
  State<AuthFlowApp> createState() => _AuthFlowAppState();
}

class _AuthFlowAppState extends State<AuthFlowApp> {
  late final AuthRepository _repository;
  late final AuthController _auth;
  late final AuthNavigation _navigation;
  late final AppearanceController _appearance;
  late final AuthDemoControls? _demo;
  late final Listenable _changes;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? createDefaultRepository();
    final repository = _repository;
    _demo = repository is AuthDemoControls
        ? repository as AuthDemoControls
        : null;
    _auth = AuthController(_repository);
    _navigation = AuthNavigation(_auth);
    _appearance = AppearanceController();
    _changes = Listenable.merge([
      _auth,
      _navigation,
      _appearance,
      ?_demo,
    ]);
    _auth.start();
  }

  @override
  void dispose() {
    _navigation.dispose();
    _auth.dispose();
    _appearance.dispose();
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      auth: _auth,
      navigation: _navigation,
      appearance: _appearance,
      demo: _demo,
      appName: widget.appName,
      changes: _changes,
      child: ScrollConfiguration(
        // Browsers don't drag-scroll with a mouse by default.
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
          },
        ),
        child: _ThemedShell(seedColor: widget.seedColor),
      ),
    );
  }
}

/// Applies the theme preference, then lays out the notice above the navigator.
class _ThemedShell extends StatelessWidget {
  const _ThemedShell({required this.seedColor});

  final Color seedColor;

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final brightness = scope.appearance.resolve(Theme.of(context).brightness);
    final hasNotice = scope.auth.notice != null;

    return Theme(
      data: buildAuthTheme(seedColor: seedColor, brightness: brightness),
      child: Builder(
        builder: (context) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NoticeStrip(),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    // The strip has already cleared the status bar.
                    removeTop: hasNotice,
                    child: const _AuthNavigator(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Renders [AuthNavigation.stack]. Nothing else adds to this navigator.
///
/// If you add a dialog or sheet, pass `useRootNavigator: false` so it opens
/// here. On the host's root navigator it would stay open after sign-out and
/// cover the recovery screen.
class _AuthNavigator extends StatefulWidget {
  const _AuthNavigator();

  @override
  State<_AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<_AuthNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  List<Page<void>> _pages = const [];

  Page<void> _pageFor(AuthRoute route, AuthController auth) {
    final key = ValueKey(route);
    return switch (route) {
      AuthRoute.splash => _AuthPage(key: key, child: const SplashScreen()),
      AuthRoute.signIn => _AuthPage(key: key, child: const SignInScreen()),
      AuthRoute.signUp => _AuthPage(key: key, child: const SignUpScreen()),
      AuthRoute.forgotPassword => _AuthPage(
        key: key,
        child: const ForgotPasswordScreen(),
      ),
      AuthRoute.verifyEmail => _AuthPage(
        key: key,
        child: const VerifyEmailScreen(),
      ),
      AuthRoute.home => _AuthPage(key: key, child: const HomeScreen()),
      AuthRoute.settings => _AuthPage(key: key, child: const SettingsScreen()),
      AuthRoute.changePassword => _AuthPage(
        key: key,
        child: const ChangePasswordScreen(),
      ),
      AuthRoute.deleteAccount => _AuthPage(
        key: key,
        child: const DeleteAccountScreen(),
      ),
      AuthRoute.resetPassword => _AuthPage(
        key: key,
        slidesUp: true,
        // A newer link gets a fresh form. Its page stays the same one, so
        // only the form resets.
        child: ResetPasswordScreen(
          key: ValueKey(auth.recovery?.token),
          email: auth.recovery?.email ?? '',
        ),
      ),
    };
  }

  /// Keeps state in step when a page is popped by the system back button.
  /// Pages dropped by a rebuild are already gone from the stack.
  void _onDidRemovePage(Page<Object?> page) {
    final key = page.key;
    if (key is! ValueKey<AuthRoute>) return;
    if (!_pages.any((current) => current.key == key)) return;
    AuthScope.read(context).navigation.didPop(key.value);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    _pages = [
      for (final route in scope.navigation.stack) _pageFor(route, scope.auth),
    ];
    // Forwards the system back button to this navigator rather than the
    // host's root navigator.
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        pages: _pages,
        onDidRemovePage: _onDidRemovePage,
      ),
    );
  }
}

class _AuthPage extends Page<void> {
  const _AuthPage({
    required LocalKey super.key,
    required this.child,
    this.slidesUp = false,
  });

  final Widget child;

  /// Rises from the bottom, because it arrives from outside the current flow.
  final bool slidesUp;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          (ModalRoute.of(context)!.settings as _AuthPage).child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween(
            begin: slidesUp ? const Offset(0, 1) : const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: slidesUp
              ? child
              : FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}
