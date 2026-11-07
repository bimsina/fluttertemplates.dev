import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Slice {
  const _Slice(this.label, this.gigabytes);

  final String label;
  final double gigabytes;
}

const _slices = [
  _Slice('Videos', 48.2),
  _Slice('Photos', 31.6),
  _Slice('Documents', 14.1),
  _Slice('Backups', 9.4),
  _Slice('Other', 4.7),
];

final _total = _slices.fold(0.0, (sum, s) => sum + s.gigabytes);

class AnalyticsDonutChart extends StatefulWidget {
  const AnalyticsDonutChart({super.key});

  @override
  State<AnalyticsDonutChart> createState() => _AnalyticsDonutChartState();
}

class _AnalyticsDonutChartState extends State<AnalyticsDonutChart> {
  int? _selected;
  int? _hover;

  int? get _active => _hover ?? _selected;

  /// Maps a pointer to a slice by radius first, then by angle from 12 o'clock.
  int? _sliceAt(Offset position, Size size) {
    final vector = position - size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final distance = vector.distance;
    if (distance > outer || distance < outer * _DonutPainter.holeRatio) {
      return null;
    }
    var angle = math.atan2(vector.dy, vector.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    var start = 0.0;
    for (var i = 0; i < _slices.length; i++) {
      final sweep = _slices[i].gigabytes / _total * 2 * math.pi;
      if (angle >= start && angle < start + sweep) return i;
      start += sweep;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Light and dark tones alternate so neighbours stay apart without relying
    // on hue, which the tonal palettes of a Material scheme keep close together.
    final colors = [
      scheme.primary,
      scheme.inversePrimary,
      scheme.tertiary,
      scheme.tertiaryContainer,
      scheme.outline,
    ];
    final active = _active;

    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: SizedBox.square(
              dimension: 240,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return MouseRegion(
                    cursor: _hover == null
                        ? MouseCursor.defer
                        : SystemMouseCursors.click,
                    onHover: (e) {
                      final slice = _sliceAt(e.localPosition, size);
                      if (slice != _hover) setState(() => _hover = slice);
                    },
                    onExit: (_) => setState(() => _hover = null),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (d) {
                        final slice = _sliceAt(d.localPosition, size);
                        setState(() {
                          _selected = slice == _selected ? null : slice;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Semantics(
                            label:
                                'Donut chart of ${_total.toStringAsFixed(0)} gigabytes of storage by file type',
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                              builder: (context, sweep, _) => CustomPaint(
                                size: size,
                                painter: _DonutPainter(
                                  colors: colors,
                                  active: active,
                                  sweep: sweep,
                                  gapColor: scheme.surface,
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(child: _CenterLabel(active: active)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < _slices.length; i++)
            _LegendRow(
              slice: _slices[i],
              color: colors[i],
              selected: active == i,
              onTap: () => setState(() {
                _selected = _selected == i ? null : i;
              }),
            ),
        ],
      ),
    );
  }
}

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({required this.active});

  final int? active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slice = active == null ? null : _slices[active!];
    final value = slice?.gigabytes ?? _total;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: Column(
        key: ValueKey(active),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${value.toStringAsFixed(1)} GB',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            slice?.label ?? 'Used of 128 GB',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final _Slice slice;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(slice.label, style: theme.textTheme.bodyMedium),
              ),
              Text(
                '${slice.gigabytes.toStringAsFixed(1)} GB',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${(slice.gigabytes / _total * 100).round()}%',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.colors,
    required this.active,
    required this.sweep,
    required this.gapColor,
  });

  static const holeRatio = 0.62;

  final List<Color> colors;
  final int? active;
  final double sweep;
  final Color gapColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final thickness = outer * (1 - holeRatio);
    var start = -math.pi / 2;

    final angles = <double>[];
    for (var i = 0; i < _slices.length; i++) {
      final angle = _slices[i].gigabytes / _total * 2 * math.pi * sweep;
      final isActive = active == i;
      // The active slice is full width; the rest sit slightly inside it.
      final width = isActive ? thickness : thickness - 8;
      final radius = outer - (isActive ? thickness / 2 : thickness / 2 + 4);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        angle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = active == null || isActive
              ? colors[i]
              : colors[i].withValues(alpha: 0.45),
      );
      angles.add(start);
      start += angle;
    }

    // Surface-coloured spokes separate the slices at any size.
    final gap = Paint()
      ..color = gapColor
      ..strokeWidth = 2;
    for (final angle in angles) {
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (outer - thickness - 1),
        center + direction * (outer + 1),
        gap,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.active != active ||
      old.sweep != sweep ||
      old.gapColor != gapColor ||
      old.colors.first != colors.first;
}
