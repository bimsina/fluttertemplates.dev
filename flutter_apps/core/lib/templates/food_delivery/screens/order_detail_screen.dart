import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../state/app_scope.dart';
import '../widgets/cart_actions.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import '../widgets/order_lines.dart';
import '../widgets/ticket.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = OrdersScope.of(context).byId(orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: const EmptyState(
          title: 'Order not found',
          message: 'This order is no longer available.',
        ),
      );
    }
    return FoodTheme(
      seed: order.restaurant.seedColor,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final muted = theme.colorScheme.onSurfaceVariant;
          return Scaffold(
            appBar: AppBar(title: Text(order.id)),
            bottomNavigationBar: order.isActive
                ? null
                : BottomActionBar(
                    child: FilledButton(
                      onPressed: () => reorder(context, order),
                      child: const Text('Order this again'),
                    ),
                  ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          DishArt(kind: order.restaurant.kind, size: 64),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.restaurant.name,
                                  style: theme.textTheme.titleLarge,
                                ),
                                Text(
                                  '${order.status.title}, '
                                  '${formatDate(order.placedAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OrderLines(lines: order.lines),
                      const SizedBox(height: 14),
                      ReceiptCard(prices: order.prices),
                      const SizedBox(height: 18),
                      _Detail(
                        icon: Icons.place_outlined,
                        title: order.address.singleLine,
                        subtitle: order.address.instructions,
                      ),
                      _Detail(
                        icon: Icons.payments_outlined,
                        title: order.payment.label,
                        subtitle: 'Delivered by ${order.courierName}',
                      ),
                    ],
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

class _Detail extends StatelessWidget {
  const _Detail({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
