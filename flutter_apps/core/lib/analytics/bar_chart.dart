import 'dart:math' as math;

import 'package:flutter/material.dart';

enum _Layout { stacked, grouped }

class _Week {
  const _Week(this.label, this.values);

  final String label;

  /// One value per channel, in the same order as [_channels].
  final List<int> values;

  int get total => values.reduce((a, b) => a + b);
}

const _channels = ['Organic', 'Paid', 'Referral'];

const _weeks = [
  _Week('W1', [120, 64, 28]),
  _Week('W2', [134, 58, 35]),
  _Week('W3', [118, 92, 31]),
  _Week('W4', [156, 88, 47]),
  _Week('W5', [171, 76, 52]),
  _Week('W6', [188, 104, 66]),
];

class AnalyticsBarChart extends StatefulWidget {
  const AnalyticsBarChart({super.key});

  @override
  State<AnalyticsBarChart> createState() => _AnalyticsBarChartState();
}

class _AnalyticsBarChartState extends State<AnalyticsBarChart> {
  var _layout = _Layout.stacked;
  var _selected = _weeks.length - 1;
  final _visible = {0, 1, 2};

  void _selectAt(double dx, double width) {
    final plot = width - _BarPainter.left;
    final index = ((dx - _BarPainter.left) / plot * _weeks.length)
        .floor()
        .clamp(0, _weeks.length - 1);
    if (index != _selected) setState(() => _selected = index);
  }

  void _toggle(int channel) {
    setState(() {
      // Keep one channel on, otherwise the chart has nothing to scale against.
      if (_visible.contains(channel) && _visible.length > 1) {
        _visible.remove(channel);
      } else {
        _visible.add(channel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Assigned by channel, so hiding one never repaints the others.
    final colors = [scheme.primary, scheme.inversePrimary, scheme.tertiary];
    final week = _weeks[_selected];
    final shown = [
      for (var i = 0; i < _channels.length; i++)
        if (_visible.contains(i)) i,
    ];
    final selectedTotal = shown.fold(0, (sum, i) => sum + week.values[i]);

    return Scaffold(
      appBar: AppBar(title: const Text('Signups by channel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<_Layout>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Layout.stacked, label: Text('Stacked')),
              ButtonSegment(value: _Layout.grouped, label: Text('Grouped')),
            ],
            selected: {_layout},
            onSelectionChanged: (s) => setState(() => _layout = s.first),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < _channels.length; i++)
                FilterChip(
                  avatar: CircleAvatar(backgroundColor: colors[i], radius: 6),
                  showCheckmark: false,
                  label: Text(_channels[i]),
                  selected: _visible.contains(i),
                  onSelected: (_) => _toggle(i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return MouseRegion(
                  onHover: (e) => _selectAt(e.localPosition.dx, width),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _selectAt(d.localPosition.dx, width),
                    onHorizontalDragUpdate: (d) =>
                        _selectAt(d.localPosition.dx, width),
                    child: Semantics(
                      label: 'Bar chart of weekly signups by channel',
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_layout),
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        builder: (context, grow, _) => CustomPaint(
                          size: Size.infinite,
                          painter: _BarPainter(
                            layout: _layout,
                            shown: shown,
                            colors: colors,
                            selected: _selected,
                            grow: grow,
                            scheme: scheme,
                            labelStyle: theme.textTheme.labelSmall!
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Week ${_selected + 1}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '$selectedTotal signups',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final i in shown)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: colors[i], radius: 5),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _channels[i],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${week.values[i]}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              '${(week.values[i] / math.max(selectedTotal, 1) * 100).round()}%',
                              textAlign: TextAlign.end,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
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

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.layout,
    required this.shown,
    required this.colors,
    required this.selected,
    required this.grow,
    required this.scheme,
    required this.labelStyle,
  });

  static const left = 32.0;
  static const _bottom = 22.0;
  static const _top = 8.0;
  static const _gap = 2.0;
  static const _maxBar = 24.0;
  static const _corner = Radius.circular(4);

  final _Layout layout;
  final List<int> shown;
  final List<Color> colors;
  final int selected;
  final double grow;
  final ColorScheme scheme;
  final TextStyle labelStyle;

  double get _peak {
    var peak = 1;
    for (final week in _weeks) {
      final values = shown.map((i) => week.values[i]);
      final top = layout == _Layout.stacked
          ? values.reduce((a, b) => a + b)
          : values.reduce(math.max);
      peak = math.max(peak, top);
    }
    return peak.toDouble();
  }

  /// 4 even ticks on a round step, so the axis stays readable as channels hide.
  double get _step {
    final raw = _peak / 4;
    final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor());
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (m * magnitude >= raw) return m * magnitude;
    }
    return raw;
  }

  void _text(Canvas canvas, String text, Offset center, {bool end = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = end ? painter.width : painter.width / 2;
    painter.paint(canvas, center - Offset(dx, painter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height - _bottom;
    final plotHeight = baseline - _top;
    final step = _step;
    final axisMax = step * 4;
    final grid = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = baseline - plotHeight * i / 4;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
      _text(canvas, '${(step * i).round()}', Offset(left - 6, y), end: true);
    }

    final band = (size.width - left) / _weeks.length;
    for (var w = 0; w < _weeks.length; w++) {
      final week = _weeks[w];
      final center = left + band * (w + 0.5);
      if (w == selected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left + band * w + 1, _top, band - 2, plotHeight),
            const Radius.circular(6),
          ),
          Paint()..color = scheme.onSurface.withValues(alpha: 0.06),
        );
      }
      _text(canvas, week.label, Offset(center, baseline + _bottom / 2 + 1));

      if (layout == _Layout.stacked) {
        final width = math.min(_maxBar, band * 0.6);
        var y = baseline;
        for (var s = 0; s < shown.length; s++) {
          final channel = shown[s];
          final height = week.values[channel] / axisMax * plotHeight * grow;
          final isTop = s == shown.length - 1;
          final rect = Rect.fromLTRB(
            center - width / 2,
            y - height,
            center + width / 2,
            y - (s == 0 ? 0 : _gap),
          );
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              rect,
              topLeft: isTop ? _corner : Radius.zero,
              topRight: isTop ? _corner : Radius.zero,
            ),
            Paint()..color = colors[channel],
          );
          y -= height;
        }
      } else {
        final count = shown.length;
        final width = math.min(
          _maxBar,
          (band * 0.8 - _gap * (count - 1)) / count,
        );
        final groupWidth = width * count + _gap * (count - 1);
        for (var s = 0; s < count; s++) {
          final channel = shown[s];
          final height = week.values[channel] / axisMax * plotHeight * grow;
          final x = center - groupWidth / 2 + s * (width + _gap);
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(x, baseline - height, width, height),
              topLeft: _corner,
              topRight: _corner,
            ),
            Paint()..color = colors[channel],
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.layout != layout ||
      old.selected != selected ||
      old.grow != grow ||
      old.scheme != scheme ||
      old.shown.length != shown.length ||
      !old.shown.every(shown.contains);
}
