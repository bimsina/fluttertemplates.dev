import 'dart:math' as math;

import 'package:flutter/material.dart';

enum _Metric {
  sessions('Sessions', 'sessions'),
  errors('Errors', 'errors');

  const _Metric(this.label, this.unit);
  final String label;
  final String unit;
}

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Two-hour buckets keep every cell a usable tap target on a phone.
const _buckets = 12;
const _bins = 5;

/// Fake demand curve: a working-day hump for sessions, a late spike for errors.
List<List<int>> _generate(_Metric metric) {
  final random = math.Random(metric.index + 3);
  return List.generate(_days.length, (day) {
    final weekend = day >= 5;
    return List.generate(_buckets, (bucket) {
      final hour = bucket * 2 + 1;
      final double value;
      if (metric == _Metric.sessions) {
        final peak = weekend ? 15.0 : 13.0;
        final spread = weekend ? 5.0 : 4.0;
        final curve = math.exp(-math.pow(hour - peak, 2) / (2 * spread * spread));
        value = curve * (weekend ? 240 : 420) + random.nextDouble() * 40;
      } else {
        final curve = math.exp(-math.pow(hour - 21, 2) / 18);
        value = curve * (day == 4 ? 70 : 34) + random.nextDouble() * 9;
      }
      return value.round();
    });
  });
}

String _slot(int bucket) {
  String pad(int h) => '${(h % 24).toString().padLeft(2, '0')}:00';
  return '${pad(bucket * 2)}–${pad(bucket * 2 + 2)}';
}

class ActivityHeatmap extends StatefulWidget {
  const ActivityHeatmap({super.key});

  @override
  State<ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {
  final _data = {for (final m in _Metric.values) m: _generate(m)};
  var _metric = _Metric.sessions;
  ({int day, int bucket})? _selected;

  List<List<int>> get _grid => _data[_metric]!;

  int get _peak => _grid.expand((row) => row).reduce(math.max);

  ({int day, int bucket}) get _busiest {
    var best = (day: 0, bucket: 0);
    for (var d = 0; d < _days.length; d++) {
      for (var b = 0; b < _buckets; b++) {
        if (_grid[d][b] > _grid[best.day][best.bucket]) {
          best = (day: d, bucket: b);
        }
      }
    }
    return best;
  }

  void _selectAt(Offset position, Size size) {
    final cell = _HeatmapPainter.cellAt(position, size);
    if (cell != null && cell != _selected) setState(() => _selected = cell);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final peak = _peak;
    final focus = _selected ?? _busiest;
    final value = _grid[focus.day][focus.bucket];
    final dayTotal = _grid[focus.day].reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly activity')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<_Metric>(
            showSelectedIcon: false,
            segments: [
              for (final m in _Metric.values)
                ButtonSegment(value: m, label: Text(m.label)),
            ],
            selected: {_metric},
            onSelectionChanged: (s) => setState(() {
              _metric = s.first;
              _selected = null;
            }),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(
                constraints.maxWidth,
                _HeatmapPainter.heightFor(constraints.maxWidth),
              );
              return MouseRegion(
                onHover: (e) => _selectAt(e.localPosition, size),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _selectAt(d.localPosition, size),
                  onPanUpdate: (d) => _selectAt(d.localPosition, size),
                  child: Semantics(
                    label:
                        '${_metric.label} by day and time, peak ${_metric.unit} $peak',
                    child: CustomPaint(
                      size: size,
                      painter: _HeatmapPainter(
                        grid: _grid,
                        peak: peak,
                        selected: focus,
                        scheme: scheme,
                        labelStyle: theme.textTheme.labelSmall!
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: theme.textTheme.labelSmall),
              const SizedBox(width: 6),
              for (var bin = 0; bin < _bins; bin++)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: _binColor(scheme, bin),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(width: 4),
              Text('More', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == null ? 'Busiest slot' : 'Selected slot',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_days[focus.day]} ${_slot(focus.bucket)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$value ${_metric.unit}, ${(value / dayTotal * 100).round()}% '
                    'of ${_days[focus.day]}\'s total of $dayTotal.',
                    style: theme.textTheme.bodyMedium,
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

/// One hue from empty track to full primary, in fixed steps so a legend works.
Color _binColor(ColorScheme scheme, int bin) => Color.lerp(
      scheme.surfaceContainerHighest,
      scheme.primary,
      bin / (_bins - 1),
    )!;

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.grid,
    required this.peak,
    required this.selected,
    required this.scheme,
    required this.labelStyle,
  });

  static const _left = 32.0;
  static const _top = 18.0;
  static const _gap = 2.0;

  final List<List<int>> grid;
  final int peak;
  final ({int day, int bucket}) selected;
  final ColorScheme scheme;
  final TextStyle labelStyle;

  static double _cellWidth(double width) => (width - _left) / _buckets;

  static double _rowHeight(double width) =>
      math.min(40, math.max(26, _cellWidth(width) * 1.4));

  static double heightFor(double width) =>
      _top + _rowHeight(width) * _days.length;

  static ({int day, int bucket})? cellAt(Offset position, Size size) {
    final bucket = ((position.dx - _left) / _cellWidth(size.width)).floor();
    final day = ((position.dy - _top) / _rowHeight(size.width)).floor();
    if (bucket < 0 || bucket >= _buckets || day < 0 || day >= _days.length) {
      return null;
    }
    return (day: day, bucket: bucket);
  }

  void _text(Canvas canvas, String text, Offset at) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(0, painter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = _cellWidth(size.width);
    final rowHeight = _rowHeight(size.width);

    for (var bucket = 0; bucket < _buckets; bucket += 3) {
      _text(
        canvas,
        '${(bucket * 2).toString().padLeft(2, '0')}h',
        Offset(_left + cellWidth * bucket, _top / 2 - 2),
      );
    }

    for (var day = 0; day < _days.length; day++) {
      final y = _top + rowHeight * day;
      _text(canvas, _days[day], Offset(0, y + rowHeight / 2));

      for (var bucket = 0; bucket < _buckets; bucket++) {
        final bin = (grid[day][bucket] / peak * (_bins - 1)).round();
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            _left + cellWidth * bucket,
            y,
            cellWidth - _gap,
            rowHeight - _gap,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, Paint()..color = _binColor(scheme, bin));
      }
    }

    final ring = Rect.fromLTWH(
      _left + cellWidth * selected.bucket,
      _top + rowHeight * selected.day,
      cellWidth - _gap,
      rowHeight - _gap,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ring.inflate(1), const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = scheme.onSurface,
    );
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.grid != grid || old.selected != selected || old.scheme != scheme;
}
