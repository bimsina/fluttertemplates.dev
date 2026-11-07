import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../models/order.dart';
import '../state/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/food_theme.dart';
import '../widgets/layout.dart';
import '../widgets/order_lines.dart';
import '../widgets/route_map.dart';
import '../widgets/status_timeline.dart';
import 'order_detail_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.orderId});

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
      child: Scaffold(
        appBar: AppBar(title: Text(order.restaurant.name)),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final map = ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: RouteMap(progress: order.progress),
            );
            final panel = _Panel(order: order);
            if (constraints.maxWidth >= wideBreakpoint) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: map),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(child: panel),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                SizedBox(
                  height: (constraints.maxHeight * 0.4).clamp(200, 340),
                  child: map,
                ),
                const SizedBox(height: 18),
                panel,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Headline(order: order),
        if (OrdersScope.of(context).hasTrackingError(order.id)) ...[
          const SizedBox(height: 12),
          TrackingErrorNotice(orderId: order.id),
        ],
        const SizedBox(height: 12),
        _ProgressBar(progress: order.progress),
        const SizedBox(height: 20),
        StatusTimeline(status: order.status),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(order.courierName.substring(0, 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.courierName, style: theme.textTheme.titleSmall),
                    Text(
                      'Your courier, delivering to ${order.address.singleLine}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                pluralize(order.itemCount, 'item'),
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderDetailScreen(orderId: order.id),
                ),
              ),
              child: const Text('View receipt'),
            ),
          ],
        ),
        OrderLines(lines: order.lines),
        if (!order.isActive) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Done'),
          ),
        ],
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final arrival = order.placedAt.add(
      Duration(minutes: order.restaurant.etaMinutes),
    );
    final String title;
    final String subtitle;
    if (order.isActive) {
      title = order.minutesRemaining <= 1
          ? 'Almost there'
          : '${order.minutesRemaining} min';
      subtitle = order.scheduledFor != null
          ? 'Scheduled for ${order.scheduledFor}'
          : 'Arriving by ${formatClock(arrival)}';
    } else {
      title = 'Delivered';
      subtitle = 'Enjoy your meal';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            title,
            key: ValueKey(title),
            style: theme.textTheme.headlineLarge,
          ),
        ),
        Text(
          '$subtitle  |  ${order.id}',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 8,
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, _) => FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: ColoredBox(color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
