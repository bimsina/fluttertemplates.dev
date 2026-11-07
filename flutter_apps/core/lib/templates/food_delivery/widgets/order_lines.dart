import 'package:flutter/material.dart';

import '../models/cart_line.dart';
import '../models/formatting.dart';

/// Read-only list of what was ordered.
class OrderLines extends StatelessWidget {
  const OrderLines({super.key, required this.lines});

  final List<CartLine> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${line.quantity}x',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.item.name, style: theme.textTheme.titleSmall),
                      if (line.selected.isNotEmpty)
                        Text(
                          line.optionsSummary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatMoney(line.totalCents),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
