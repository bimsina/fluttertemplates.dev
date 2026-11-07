import 'package:flutter/widgets.dart';

import 'pos_store.dart';

/// Exposes the [PosStore] to the widget tree and rebuilds dependents when it
/// notifies.
class PosScope extends InheritedNotifier<PosStore> {
  const PosScope({super.key, required PosStore store, required super.child})
    : super(notifier: store);

  /// Reads the store and rebuilds [context] on every change.
  static PosStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PosScope>()!.notifier!;

  /// Reads the store without subscribing. Use this in callbacks.
  static PosStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PosScope>()!.notifier!;
}
