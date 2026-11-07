import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../state/app_scope.dart';
import 'dish_art.dart';

/// Empty plate, a message and an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.kind,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final DishKind? kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DishArt(kind: kind, size: 132),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 24),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small label and icon pair used for restaurant facts.
class Fact extends StatelessWidget {
  const Fact({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.compact = false,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimension = compact ? 34.0 : 44.0;

    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) {
      return SizedBox.square(
        dimension: dimension,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          iconSize: compact ? 17 : 21,
          color: scheme.onSecondaryContainer,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            quantity <= 1 && min == 0 ? Icons.delete_outline : Icons.remove,
            quantity <= 1 && min == 0 ? 'Remove' : 'Decrease quantity',
            quantity > min ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: compact ? 22 : 28,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          button(
            Icons.add,
            'Increase quantity',
            quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

/// Grey placeholder block that gently pulses while data loads.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.height, this.width, this.radius = 24});

  final double? height;
  final double? width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.45,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Circular or square marker for single and multi choice rows.
class ChoiceMark extends StatelessWidget {
  const ChoiceMark({
    super.key,
    required this.selected,
    required this.single,
    this.enabled = true,
  });

  final bool selected;
  final bool single;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? scheme.primary : Colors.transparent,
        shape: single ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: single ? null : BorderRadius.circular(6),
        border: Border.all(
          width: 2,
          color: selected
              ? scheme.primary
              : enabled
              ? scheme.outline
              : scheme.outlineVariant,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 15, color: scheme.onPrimary)
          : null,
    );
  }
}

/// Says that an order's live status stopped updating, with a retry. The order
/// itself is fine, so this sits beside it and never replaces it.
class TrackingErrorNotice extends StatelessWidget {
  const TrackingErrorNotice({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.sync_problem, size: 20, color: scheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Live tracking stopped for $orderId. This status may be out '
                'of date.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () => OrdersScope.read(context).retryTracking(orderId),
              style: TextButton.styleFrom(
                foregroundColor: scheme.onErrorContainer,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
