import 'package:flutter/widgets.dart';

import '../data/auth_demo_controls.dart';
import 'appearance_controller.dart';
import 'auth_controller.dart';
import 'auth_navigation.dart';

/// Hands the controllers to the widget tree, and rebuilds dependents when any
/// of them change.
class AuthScope extends InheritedNotifier<Listenable> {
  const AuthScope({
    super.key,
    required this.auth,
    required this.navigation,
    required this.appearance,
    required this.demo,
    required this.appName,
    required Listenable changes,
    required super.child,
  }) : super(notifier: changes);

  final AuthController auth;
  final AuthNavigation navigation;
  final AppearanceController appearance;

  /// Null with a real backend, which hides every demo panel.
  final AuthDemoControls? demo;
  final String appName;

  /// For `build` methods. Rebuilds the caller on every change.
  static AuthScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!;

  /// For callbacks and `initState`. Doesn't subscribe to changes.
  static AuthScope read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AuthScope>()!;
}
