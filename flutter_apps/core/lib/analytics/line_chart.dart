import 'dart:math' as math;

import 'package:flutter/material.dart';

enum _Range {
  week('7D', 7),
  month('30D', 30),
  quarter('90D', 90);

  const _Range(this.label, this.days);
  final String label;
  final int days;
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _dateLabel(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String _money(double v) {
  final whole = v.round().toString();
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => ',',
  );
  return '\$$grouped';
}

String _axisMoney(double v) =>
    v >= 1000 ? '\$${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K' : '\$${v.round()}';

/// Seeded so the demo data is stable between rebuilds. Swap for real values.
List<double> _revenue(int seed, int days, double base) {
  final random = math.Random(seed);
  return List.generate(days, (i) {
    final weekly = math.sin(i / 7 * 2 * math.pi) * base * 0.12;
    final trend = i / days * base * 0.25;
    return base + weekly + trend + random.nextDouble() * base * 0.14;
  });
}

/// Rounds the top of the axis up to the next value that divides into 4 clean ticks.
double _niceMax(double value) {
  final magnitude = math.pow(10, (math.log(value) / math.ln10).floor());
  for (final step in const [1.0, 1.2, 1.6, 2.0, 2.4, 3.0, 4.0, 6.0, 8.0, 10.0]) {
    if (step * magnitude >= value) return step * magnitude;
  }
  return value;
}

class AnalyticsLineChart extends StatefulWidget {
  const AnalyticsLineChart({super.key});

  @override
  State<AnalyticsLineChart> createState() => _AnalyticsLineChartState();
}

class _AnalyticsLineChartState extends State<AnalyticsLineChart> {
  var _range = _Range.month;
  var _showPrevious = true;
  int? _hover;

  List<double> get _current => _revenue(7, _range.days, 4200);
  List<double> get _previous => _revenue(21, _range.days, 3700);

  DateTime _dayAt(int index) => DateTime.now()
      .subtract(Duration(days: _range.days - 1 - index));

  void _updateHover(double dx, double width) {
    final plot = width - _LinePainter.left - _LinePainter.right;
    final t = ((dx - _LinePainter.left) / plot).clamp(0.0, 1.0);
    final index = (t * (_range.days - 1)).round();
    if (index != _hover) setState(() => _hover = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = _current;
    final previous = _previous;
    final total = current.reduce((a, b) => a + b);
    final previousTotal = previous.reduce((a, b) => a + b);
    final change = (total - previousTotal) / previousTotal * 100;
    final peak = [...current, if (_showPrevious) ...previous].reduce(math.max);
    final maxY = _niceMax(peak);

    return Scaffold(
      appBar: AppBar(title: const Text('Revenue')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            _money(total),
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs previous ${_range.days} days',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SegmentedButton<_Range>(
            showSelectedIcon: false,
            segments: [
              for (final r in _Range.values)
                ButtonSegment(value: r, label: Text(r.label)),
            ],
            selected: {_range},
            onSelectionChanged: (s) => setState(() {
              _range = s.first;
              _hover = null;
            }),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _LegendKey(color: scheme.primary, label: 'This period'),
              _LegendKey(
                color: scheme.outline,
                label: 'Previous period',
                active: _showPrevious,
                onTap: () => setState(() => _showPrevious = !_showPrevious),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return MouseRegion(
                  onHover: (e) => _updateHover(e.localPosition.dx, width),
                  onExit: (_) => setState(() => _hover = null),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _updateHover(d.localPosition.dx, width),
                    onHorizontalDragStart: (d) =>
                        _updateHover(d.localPosition.dx, width),
                    onHorizontalDragUpdate: (d) =>
                        _updateHover(d.localPosition.dx, width),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Semantics(
                            label:
                                'Line chart of daily revenue, ${_money(total)} over ${_range.days} days',
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey(_range),
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, reveal, _) => CustomPaint(
                                painter: _LinePainter(
                                  current: current,
                                  previous: _showPrevious ? previous : null,
                                  maxY: maxY,
                                  hover: _hover,
                                  reveal: reveal,
                                  firstLabel: _dateLabel(_dayAt(0)),
                                  middleLabel:
                                      _dateLabel(_dayAt(_range.days ~/ 2)),
                                  lastLabel:
                                      _dateLabel(_dayAt(_range.days - 1)),
                                  scheme: scheme,
                                  labelStyle: theme.textTheme.labelSmall!
                                      .copyWith(
                                          color: scheme.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_hover != null)
                          _Tooltip(
                            x: _LinePainter.xFor(
                                _hover!, _range.days, width),
                            chartWidth: width,
                            date: _dateLabel(_dayAt(_hover!)),
                            current: current[_hover!],
                            previous: _showPrevious ? previous[_hover!] : null,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Figure(
                label: 'Daily average',
                value: _money(total / current.length),
              ),
              _Figure(
                label: 'Best day',
                value: _money(current.reduce(math.max)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _LegendKey extends StatelessWidget {
  const _LegendKey({
    required this.color,
    required this.label,
    this.active = true,
    this.onTap,
  });

  final Color color;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Opacity(
          opacity: active ? 1 : 0.45,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.x,
    required this.chartWidth,
    required this.date,
    required this.current,
    required this.previous,
  });

  static const _width = 136.0;

  final double x;
  final double chartWidth;
  final String date;
  final double current;
  final double? previous;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Sit beside the crosshair, flipping sides so the card never leaves the plot.
    final left = x + 12 + _width > chartWidth ? x - 12 - _width : x + 12;

    Widget row(Color color, String label, double value) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: theme.textTheme.labelSmall)),
              Text(_money(value), style: theme.textTheme.labelMedium),
            ],
          ),
        );

    return Positioned(
      left: left.clamp(0.0, math.max(0.0, chartWidth - _width)),
      top: 4,
      width: _width,
      child: IgnorePointer(
        child: Material(
          elevation: 3,
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: theme.textTheme.labelMedium),
                row(scheme.primary, 'This', current),
                if (previous != null) row(scheme.outline, 'Prev', previous!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.current,
    required this.previous,
    required this.maxY,
    required this.hover,
    required this.reveal,
    required this.firstLabel,
    required this.middleLabel,
    required this.lastLabel,
    required this.scheme,
    required this.labelStyle,
  });

  static const left = 40.0;
  static const right = 10.0;
  static const top = 8.0;
  static const bottom = 24.0;
  static const _ticks = 4;

  final List<double> current;
  final List<double>? previous;
  final double maxY;
  final int? hover;
  final double reveal;
  final String firstLabel;
  final String middleLabel;
  final String lastLabel;
  final ColorScheme scheme;
  final TextStyle labelStyle;

  static double xFor(int index, int count, double width) =>
      left + (width - left - right) * index / (count - 1);

  double _yFor(double value, double height) {
    final plot = height - top - bottom;
    return top + plot * (1 - value / maxY);
  }

  void _text(Canvas canvas, String text, Offset at, {double alignX = 0}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width * alignX, painter.height / 2));
  }

  Path _path(List<double> values, Size size) {
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = xFor(i, values.length, size.width);
      final y = _yFor(values[i], size.height);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (var i = 0; i <= _ticks; i++) {
      final value = maxY / _ticks * i;
      final y = _yFor(value, size.height);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid);
      _text(canvas, _axisMoney(value), Offset(left - 6, y), alignX: 1);
    }

    final labelY = size.height - bottom / 2 + 2;
    _text(canvas, firstLabel, Offset(left, labelY));
    _text(canvas, middleLabel, Offset((left + size.width - right) / 2, labelY),
        alignX: 0.5);
    _text(canvas, lastLabel, Offset(size.width - right, labelY), alignX: 1);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * reveal, size.height));

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (previous != null) {
      canvas.drawPath(_path(previous!, size), line..color = scheme.outline);
    }

    final currentPath = _path(current, size);
    final baseline = _yFor(0, size.height);
    final area = Path.from(currentPath)
      ..lineTo(size.width - right, baseline)
      ..lineTo(left, baseline)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = scheme.primary.withValues(alpha: 0.1),
    );
    canvas.drawPath(currentPath, line..color = scheme.primary);
    canvas.restore();

    final index = hover;
    if (index == null) return;

    final x = xFor(index, current.length, size.width);
    canvas.drawLine(
      Offset(x, top),
      Offset(x, baseline),
      Paint()
        ..color = scheme.outline
        ..strokeWidth = 1,
    );
    _dot(canvas, Offset(x, _yFor(current[index], size.height)), scheme.primary);
    if (previous != null) {
      _dot(canvas, Offset(x, _yFor(previous![index], size.height)),
          scheme.outline);
    }
  }

  void _dot(Canvas canvas, Offset at, Color color) {
    canvas.drawCircle(at, 6, Paint()..color = scheme.surface);
    canvas.drawCircle(at, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.current != current ||
      old.previous != previous ||
      old.hover != hover ||
      old.reveal != reveal ||
      old.scheme != scheme;
}
