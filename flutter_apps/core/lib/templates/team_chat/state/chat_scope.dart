import 'package:flutter/widgets.dart';

import 'chat_store.dart';

/// Exposes [ChatStore] to the tree and rebuilds dependents when it changes.
class ChatScope extends InheritedNotifier<ChatStore> {
  const ChatScope({super.key, required ChatStore store, required super.child})
    : super(notifier: store);

  /// Reads the store and rebuilds [context] on every change.
  static ChatStore of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChatScope>()!.notifier!;
  }

  /// Reads the store without subscribing. Use it in callbacks and `initState`.
  static ChatStore read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<ChatScope>()!.notifier!;
  }
}
