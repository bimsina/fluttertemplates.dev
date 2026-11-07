import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../state/spending_insights.dart';
import 'category_style.dart';
import 'money_text.dart';

/// Monthly spending as bars drawn with [CustomPaint]. Bars are one hue, with
/// the selected month emphasized. A dashed line marks the average.
///
/// Taps go through a row of [InkWell]s laid over the painting, which also
/// gives every bar hover, keyboard focus, and a screen reader label.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.months,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 190,
  });

  final List<MonthlySpending> months;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final values = [for (final month in months) month.totalCents];
    final nonZero = values.where((value) => value > 0).toList();
    final average = nonZero.isEmpty
        ? 0
        : nonZero.reduce((a, b) => a + b) ~/ nonZero.length;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, _) {
                      return CustomPaint(
                        painter: _MonthlyBarsPainter(
                          values: values,
                          selectedIndex: selectedIndex,
                          average: average,
                          progress: progress,
                          barColor: scheme.primary.withValues(alpha: 0.28),
                          selectedColor: scheme.primary,
                          guideColor: scheme.onSurfaceVariant,
                          baselineColor: scheme.outlineVariant,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      for (var i = 0; i < months.length; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: i == selectedIndex,
                            label:
                                '${monthLong(months[i].month)}, '
                                '${formatCents(months[i].totalCents)} spent',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => onSelected(i),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < months.length; i++)
                  Expanded(
                    child: Text(
                      monthShort(months[i].month),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: i == selectedIndex
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: i == selectedIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBarsPainter extends CustomPainter {
  const _MonthlyBarsPainter({
    required this.values,
    required this.selectedIndex,
    required this.average,
    required this.progress,
    required this.barColor,
    required this.selectedColor,
    required this.guideColor,
    required this.baselineColor,
  });

  final List<int> values;
  final int selectedIndex;
  final int average;
  final double progress;
  final Color barColor;
  final Color selectedColor;
  final Color guideColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final peak = values.reduce((a, b) => a > b ? a : b);
    final slot = size.width / values.length;
    final barWidth = (slot * 0.56).clamp(8.0, 44.0);
    const topPadding = 6.0;
    final plotHeight = size.height - topPadding;

    for (var i = 0; i < values.length; i++) {
      final fraction = peak == 0 ? 0.0 : values[i] / peak;
      // An empty month still gets a sliver, so its slot doesn't look missing.
      final barHeight = (plotHeight * fraction * progress).clamp(
        2.0,
        plotHeight,
      );
      final left = slot * i + (slot - barWidth) / 2;
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = i == selectedIndex ? selectedColor : barColor,
      );
    }

    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );

    if (peak > 0 && average > 0) {
      final y = size.height - plotHeight * (average / peak) * progress;
      final guide = Paint()
        ..color = guideColor
        ..strokeWidth = 1.2;
      for (double x = 0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), guide);
      }
    }
  }

  @override
  bool shouldRepaint(_MonthlyBarsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.average != average ||
        oldDelegate.barColor != barColor ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.baselineColor != baselineColor ||
        !_sameValues(oldDelegate.values);
  }

  bool _sameValues(List<int> other) {
    if (other.length != values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (other[i] != values[i]) return false;
    }
    return true;
  }
}

/// One ranked row of the category breakdown. Bars share a single hue because
/// the length carries the meaning and the label carries the identity.
class CategoryBarRow extends StatelessWidget {
  const CategoryBarRow({
    super.key,
    required this.item,
    required this.totalCents,
    required this.largestCents,
    required this.onTap,
  });

  final CategorySpending item;
  final int totalCents;
  final int largestCents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final share = totalCents == 0 ? 0 : (item.cents * 100 / totalCents).round();
    final fraction = largestCents == 0 ? 0.0 : item.cents / largestCents;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            CategoryIcon(category: item.category, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.category.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MoneyText(item.cents, style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: fraction),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CustomPaint(
                              size: const Size(double.infinity, 6),
                              painter: _ShareBarPainter(
                                fraction: value,
                                fill: scheme.primary,
                                track: scheme.surfaceContainerHigh,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '$share%',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareBarPainter extends CustomPainter {
  const _ShareBarPainter({
    required this.fraction,
    required this.fill,
    required this.track,
  });

  final double fraction;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = track,
    );
    if (fraction <= 0) return;
    final width = (size.width * fraction).clamp(size.height, size.width);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, size.height), radius),
      Paint()..color = fill,
    );
  }

  @override
  bool shouldRepaint(_ShareBarPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.fill != fill ||
        oldDelegate.track != track;
  }
}
