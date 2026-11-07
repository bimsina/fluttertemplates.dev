import 'package:flutter/material.dart';

import '../models/format.dart';
import 'pos_theme.dart';

/// Takings per hour for one day. One series, so the title names it and only
/// the peak carries a number. Hover or long-press a bar for its value.
class HourlyBars extends StatelessWidget {
  const HourlyBars({super.key, required this.hourlyCents, this.height = 148});

  final List<int> hourlyCents;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.labelSmall!.tabular.copyWith(
      color: scheme.onSurfaceVariant,
    );

    // Trading hours by default, stretched to fit any sale outside them.
    var first = 8;
    var last = 20;
    for (var hour = 0; hour < 24; hour++) {
      if (hourlyCents[hour] > 0) {
        if (hour < first) first = hour;
        if (hour > last) last = hour;
      }
    }
    final hours = [for (var hour = first; hour <= last; hour++) hour];
    final peak = hours
        .map((hour) => hourlyCents[hour])
        .reduce((a, b) => a > b ? a : b);

    return Semantics(
      label:
          'Takings by hour. Peak ${formatMoney(peak)}. '
          'The sales list below has every transaction.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final hour in hours)
                  Expanded(
                    child: _Bar(
                      hour: hour,
                      cents: hourlyCents[hour],
                      peak: peak,
                      labelPeak: peak > 0 && hourlyCents[hour] == peak,
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final hour in hours)
                Expanded(
                  child: Center(
                    child: (hour - first) % 4 == 0
                        ? Text(
                            formatHour(hour).replaceAll(' ', ''),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: muted,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.hour,
    required this.cents,
    required this.peak,
    required this.labelPeak,
  });

  final int hour;
  final int cents;
  final int peak;
  final bool labelPeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Tooltip(
      message: '${formatHour(hour)}: ${formatMoney(cents)}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Leave headroom above the tallest bar for its label.
          final room = constraints.maxHeight - 20;
          final barHeight = peak == 0 ? 0.0 : room * cents / peak;
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (labelPeak)
                  SizedBox(
                    height: 18,
                    child: OverflowBox(
                      maxWidth: 80,
                      child: Text(
                        formatMoney(cents),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall!.tabular.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    height: cents > 0 && barHeight < 2 ? 2 : barHeight,
                    constraints: const BoxConstraints(maxWidth: 28),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
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

/// Cash against card. Part-to-whole with two segments, so one thin bar and a
/// labelled legend say more than a pie.
class PaymentSplit extends StatelessWidget {
  const PaymentSplit({
    super.key,
    required this.cashCents,
    required this.cardCents,
  });

  final int cashCents;
  final int cardCents;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = cashCents + cardCents;
    final cashShare = total == 0 ? 0 : (cashCents * 100 / total).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: total == 0
                ? ColoredBox(color: scheme.surfaceContainerHighest)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (cashCents > 0)
                        Expanded(
                          flex: cashCents,
                          child: ColoredBox(color: scheme.primary),
                        ),
                      if (cashCents > 0 && cardCents > 0)
                        const SizedBox(width: 2),
                      if (cardCents > 0)
                        Expanded(
                          flex: cardCents,
                          child: ColoredBox(color: scheme.tertiary),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _Legend(
          color: scheme.primary,
          label: 'Cash',
          share: cashShare,
          cents: cashCents,
        ),
        const SizedBox(height: 6),
        _Legend(
          color: scheme.tertiary,
          label: 'Card',
          share: total == 0 ? 0 : 100 - cashShare,
          cents: cardCents,
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.share,
    required this.cents,
  });

  final Color color;
  final String label;
  final int share;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          '$share%',
          style: theme.textTheme.bodySmall!.tabular.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatMoney(cents),
          style: theme.textTheme.bodyMedium!.tabular.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
