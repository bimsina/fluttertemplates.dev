import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Metric {
  const _Metric({
    required this.label,
    required this.values,
    required this.format,
    this.lowerIsBetter = false,
  });

  final String label;

  /// One value per week, oldest first.
  final List<double> values;
  final String Function(double) format;
  final bool lowerIsBetter;
}

String _dollars(double v) => '\$${(v / 1000).toStringAsFixed(1)}K';
String _count(double v) => v.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+$)'),
      (_) => ',',
    );
String _percent(double v) => '${v.toStringAsFixed(1)}%';
String _minutes(double v) => '${v.toStringAsFixed(1)} min';

final _metrics = <_Metric>[
  _Metric(
    label: 'Monthly revenue',
    values: const [
      38200, 38900, 39400, 39100, 40300, 41200,
      41000, 42600, 43100, 44800, 45200, 46900,
    ],
    format: _dollars,
  ),
  _Metric(
    label: 'Active users',
    values: const [
      8120, 8340, 8290, 8510, 8760, 8640,
      8930, 9210, 9180, 9420, 9390, 9680,
    ],
    format: _count,
  ),
  _Metric(
    label: 'Churn rate',
    values: const [
      4.2, 4.1, 4.4, 4.0, 3.9, 4.0, 3.7, 3.6, 3.8, 3.4, 3.3, 3.1,
    ],
    format: _percent,
    lowerIsBetter: true,
  ),
  _Metric(
    label: 'Avg. session',
    values: const [
      6.8, 6.5, 6.9, 6.4, 6.2, 6.3, 6.0, 6.1, 5.8, 5.9, 5.7, 5.6,
    ],
    format: _minutes,
  ),
];

class SparklineStatCards extends StatefulWidget {
  const SparklineStatCards({super.key});

  @override
  State<SparklineStatCards> createState() => _SparklineStatCardsState();
}

class _SparklineStatCardsState extends State<SparklineStatCards> {
  var _weeks = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 4, label: Text('4 weeks')),
              ButtonSegment(value: 12, label: Text('12 weeks')),
            ],
            selected: {_weeks},
            onSelectionChanged: (s) => setState(() => _weeks = s.first),
          ),
          const SizedBox(height: 8),
          Text(
            'Hover or drag across a trend to read any week.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final metric in _metrics)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StatCard(
                // A new window has a different length, so reset any scrubbing.
                key: ValueKey('${metric.label}-$_weeks'),
                metric: metric,
                weeks: _weeks,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  const _StatCard({super.key, required this.metric, required this.weeks});

  final _Metric metric;
  final int weeks;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  int? _scrub;

  List<double> get _values {
    final all = widget.metric.values;
    return all.sublist(all.length - widget.weeks);
  }

  void _scrubTo(double dx, double width) {
    final count = _values.length;
    final index = (dx / width * (count - 1)).round().clamp(0, count - 1);
    if (index != _scrub) setState(() => _scrub = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final metric = widget.metric;
    final values = _values;
    final index = _scrub ?? values.length - 1;
    final change = (values[index] - values.first) / values.first * 100;
    final improving = metric.lowerIsBetter ? change <= 0 : change >= 0;
    final deltaColor = improving ? scheme.primary : scheme.error;
    final weeksAgo = values.length - 1 - index;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.format(values[index]),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: deltaColor,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${change.abs().toStringAsFixed(1)}%'
                          '${_scrub == null ? '' : weeksAgo == 0 ? ' this week' : ' · ${weeksAgo}w ago'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 56,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return MouseRegion(
                      onHover: (e) => _scrubTo(e.localPosition.dx, width),
                      onExit: (_) => setState(() => _scrub = null),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) => _scrubTo(d.localPosition.dx, width),
                        onTapUp: (_) => setState(() => _scrub = null),
                        onHorizontalDragUpdate: (d) =>
                            _scrubTo(d.localPosition.dx, width),
                        onHorizontalDragEnd: (_) =>
                            setState(() => _scrub = null),
                        child: Semantics(
                          label: '${metric.label} trend',
                          value: metric.format(values.last),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _SparklinePainter(
                              values: values,
                              scrub: _scrub,
                              lineColor: scheme.outline,
                              accent: scheme.primary,
                              ring: scheme.surfaceContainerLow,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.scrub,
    required this.lineColor,
    required this.accent,
    required this.ring,
  });

  static const _inset = 6.0;

  final List<double> values;
  final int? scrub;
  final Color lineColor;
  final Color accent;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final spread = high == low ? 1.0 : high - low;

    Offset point(int i) => Offset(
          _inset + (size.width - _inset * 2) * i / (values.length - 1),
          _inset + (size.height - _inset * 2) * (1 - (values[i] - low) / spread),
        );

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );

    final marker = point(scrub ?? values.length - 1);
    if (scrub != null) {
      canvas.drawLine(
        Offset(marker.dx, 0),
        Offset(marker.dx, size.height),
        Paint()
          ..color = lineColor.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
    }
    canvas.drawCircle(marker, 6, Paint()..color = ring);
    canvas.drawCircle(marker, 4, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.scrub != scrub ||
      old.values != values ||
      old.accent != accent ||
      old.ring != ring;
}
