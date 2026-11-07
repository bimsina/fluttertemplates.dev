import 'package:flutter/widgets.dart';

import 'wallet_controller.dart';

/// Makes the [WalletController] available to the whole app.
class WalletScope extends InheritedNotifier<WalletController> {
  const WalletScope({
    super.key,
    required WalletController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the controller and rebuilds the caller when it changes.
  static WalletController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WalletScope>();
    assert(scope != null, 'No WalletScope above this context.');
    return scope!.notifier!;
  }

  /// Returns the controller without subscribing. Use this in callbacks.
  static WalletController read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<WalletScope>();
    assert(element != null, 'No WalletScope above this context.');
    return (element!.widget as WalletScope).notifier!;
  }
}
