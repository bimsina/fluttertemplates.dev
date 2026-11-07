import 'package:flutter/material.dart';

import '../models/order.dart';
import '../state/app_scope.dart';

/// Asks before throwing away a cart from another restaurant.
Future<bool> confirmReplaceCart(
  BuildContext context, {
  required String currentRestaurant,
  required String newRestaurant,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Start a new cart?'),
      content: Text(
        'Your cart has items from $currentRestaurant. Adding from '
        '$newRestaurant will remove them.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep cart'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Start new'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Loads an old order into the cart and shows the cart tab.
Future<void> reorder(BuildContext context, Order order) async {
  final cart = CartScope.read(context);
  final tabs = TabScope.read(context);
  final navigator = Navigator.of(context);
  final current = cart.restaurant;
  if (current != null && !cart.isEmpty) {
    final confirmed = await confirmReplaceCart(
      context,
      currentRestaurant: current.name,
      newRestaurant: order.restaurant.name,
    );
    if (!confirmed) return;
  }
  cart.reorder(order);
  tabs.value = TabScope.cart;
  navigator.popUntil((route) => route.isFirst);
}
