import 'package:flutter/material.dart';

import '../models/order.dart';

/// Vertical list of delivery steps with the current one highlighted.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    const steps = OrderStatus.values;
    return Column(
      children: [
        for (final step in steps)
          _Step(
            step: step,
            isDone:
                step.index < status.index || status == OrderStatus.delivered,
            isCurrent: step == status && status != OrderStatus.delivered,
            isLast: step == steps.last,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final OrderStatus step;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const duration = Duration(milliseconds: 300);
    final reached = isDone || isCurrent;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: duration,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    border: isCurrent
                        ? Border.all(color: scheme.primaryContainer, width: 4)
                        : null,
                  ),
                  child: isDone
                      ? Icon(Icons.check, size: 15, color: scheme.onPrimary)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: AnimatedContainer(
                      duration: duration,
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: isDone
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: reached
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  if (isCurrent)
                    Text(
                      step.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
