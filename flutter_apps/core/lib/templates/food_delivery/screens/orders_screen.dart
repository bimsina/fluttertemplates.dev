import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../models/order.dart';
import '../state/app_scope.dart';
import '../widgets/cart_actions.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import 'order_detail_screen.dart';
import 'tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// Null until the customer picks a side. Reset when an order starts or
  /// finishes, so the list follows that order instead of going empty.
  bool? _showActive;
  int _lastActiveCount = 0;

  @override
  Widget build(BuildContext context) {
    final orders = OrdersScope.of(context);
    final active = orders.active;
    final past = orders.past;
    if (active.length != _lastActiveCount) {
      _lastActiveCount = active.length;
      _showActive = null;
    }
    final showActive = _showActive ?? active.isNotEmpty;
    final visible = showActive ? active : past;

    return Scaffold(
      appBar: AppBar(title: const Text('Your orders')),
      body: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text('Active (${active.length})'),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Past (${past.length})'),
                  ),
                ],
                selected: {showActive},
                onSelectionChanged: (selection) =>
                    setState(() => _showActive = selection.first),
              ),
            ),
            if (showActive)
              for (final order in active)
                if (orders.hasTrackingError(order.id))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TrackingErrorNotice(orderId: order.id),
                  ),
            Expanded(
              child: _body(
                context,
                orders.isLoading,
                orders.hasLoadError,
                visible,
                showActive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    bool isLoading,
    bool hasError,
    List<Order> visible,
    bool showActive,
  ) {
    if (isLoading && visible.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const SkeletonBox(height: 120),
      );
    }
    if (hasError && visible.isEmpty) {
      return EmptyState(
        title: 'Could not load your orders',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: OrdersScope.read(context).load,
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        title: showActive ? 'Nothing on the way' : 'No past orders',
        message: showActive
            ? 'When you place an order you can follow it here.'
            : 'Your delivered orders will be listed here.',
        actionLabel: 'Browse restaurants',
        onAction: () => TabScope.read(context).value = TabScope.home,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _OrderCard(order: visible[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => order.isActive
            ? TrackingScreen(orderId: order.id)
            : OrderDetailScreen(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FoodTheme(
      seed: order.restaurant.seedColor,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          return Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _open(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        DishArt(kind: order.restaurant.kind, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.restaurant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                formatDate(order.placedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatMoney(order.prices.totalCents),
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.lines
                          .map((l) => '${l.quantity}x ${l.item.name}')
                          .join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (order.isActive)
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining_rounded,
                            size: 18,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.status.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          Text(
                            '${order.minutesRemaining} min',
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => reorder(context, order),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(64, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: const Text('Reorder'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
