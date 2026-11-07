import 'package:flutter/foundation.dart';

import 'auth_controller.dart';

enum AuthRoute {
  splash,
  signIn,
  signUp,
  forgotPassword,
  verifyEmail,
  home,
  settings,
  changePassword,
  deleteAccount,
  resetPassword,
}

/// Turns auth state into the page stack.
///
/// The whole stack is [stack], and the nested Navigator only renders it. There
/// are no imperative pushes anywhere, which is what makes these true:
///
/// * The root of the stack follows [AuthController.status], so signing out or
///   expiring swaps it and drops everything opened in the old state.
/// * Password recovery isn't one of those roots. It is always added last, so
///   it opens above whatever is showing and stays there if the state below it
///   changes. A gate that swapped to a reset screen at its root would instead
///   put it underneath any route already pushed, where nobody could see it.
class AuthNavigation extends ChangeNotifier {
  AuthNavigation(this._auth) {
    _zone = _currentZone;
    _auth.addListener(_onAuthChanged);
  }

  final AuthController _auth;

  /// Routes opened on top of the current root.
  final List<AuthRoute> _opened = [];
  late String _zone;

  static const _signedOutRoutes = {
    AuthRoute.signUp,
    AuthRoute.forgotPassword,
  };
  static const _signedInRoutes = {
    AuthRoute.settings,
    AuthRoute.changePassword,
    AuthRoute.deleteAccount,
  };

  /// Changes when opened routes stop making sense: on a new status, or on the
  /// same status with a different user.
  String get _currentZone => '${_auth.status.name}:${_auth.user?.id}';

  List<AuthRoute> get stack => [
    switch (_auth.status) {
      AuthStatus.restoring => AuthRoute.splash,
      AuthStatus.signedOut => AuthRoute.signIn,
      AuthStatus.awaitingVerification => AuthRoute.verifyEmail,
      AuthStatus.signedIn => AuthRoute.home,
    },
    ..._opened,
    if (_auth.recovery != null) AuthRoute.resetPassword,
  ];

  /// Opens [route] above the current one. Ignored if it's already open, or if
  /// it doesn't belong to the current status, so a stale tap can't reach a
  /// signed-in route after sign-out.
  void open(AuthRoute route) {
    final allowed = switch (_auth.status) {
      AuthStatus.signedOut => _signedOutRoutes,
      AuthStatus.signedIn => _signedInRoutes,
      _ => const <AuthRoute>{},
    };
    if (!allowed.contains(route) || _opened.contains(route)) return;
    _opened.add(route);
    // A message about the last screen doesn't belong on the next one.
    _auth.dismissNotice();
    notifyListeners();
  }

  /// Closes the top route, if it can be closed.
  void back() {
    if (_auth.recovery != null) {
      _auth.dismissRecovery();
    } else if (_opened.isNotEmpty) {
      _opened.removeLast();
      notifyListeners();
    }
  }

  /// Keeps state in step after the Navigator pops [route] itself, for example
  /// from the system back button.
  void didPop(AuthRoute route) {
    if (route == AuthRoute.resetPassword) {
      _auth.dismissRecovery();
    } else if (_opened.remove(route)) {
      notifyListeners();
    }
  }

  /// Closes everything above the current root.
  void closeAll() {
    if (_opened.isEmpty) return;
    _opened.clear();
    notifyListeners();
  }

  void _onAuthChanged() {
    final zone = _currentZone;
    if (zone == _zone) return;
    _zone = zone;
    _opened.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
