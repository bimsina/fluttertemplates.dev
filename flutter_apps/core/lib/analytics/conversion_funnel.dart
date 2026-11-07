import 'package:flutter/material.dart';

enum _Platform {
  web('Web', [18400, 6120, 3380, 1420, 610]),
  ios('iOS', [9200, 4380, 2960, 1510, 790]),
  android('Android', [12600, 4910, 2640, 980, 372]);

  const _Platform(this.label, this.counts);
  final String label;
  final List<int> counts;
}

const _stages = ['Visited', 'Signed up', 'Activated', 'Started trial', 'Paid'];

String _grouped(num v) => v.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+$)'),
      (_) => ',',
    );

class ConversionFunnel extends StatefulWidget {
  const ConversionFunnel({super.key});

  @override
  State<ConversionFunnel> createState() => _ConversionFunnelState();
}

class _ConversionFunnelState extends State<ConversionFunnel> {
  var _platform = _Platform.web;
  var _selected = 1;

  void _selectAt(double dy) {
    final index =
        (dy / _FunnelPainter.rowHeight).floor().clamp(0, _stages.length - 1);
    if (index != _selected) setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final counts = _platform.counts;
    final count = counts[_selected];
    final overall = count / counts.first * 100;
    final fromPrevious =
        _selected == 0 ? 100.0 : count / counts[_selected - 1] * 100;
    final lost = _selected == 0 ? 0 : counts[_selected - 1] - count;

    return Scaffold(
      appBar: AppBar(title: const Text('Conversion funnel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<_Platform>(
            showSelectedIcon: false,
            segments: [
              for (final p in _Platform.values)
                ButtonSegment(value: p, label: Text(p.label)),
            ],
            selected: {_platform},
            onSelectionChanged: (s) => setState(() => _platform = s.first),
          ),
          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (e) => _selectAt(e.localPosition.dy),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _selectAt(d.localPosition.dy),
              child: Semantics(
                label: 'Funnel from ${_grouped(counts.first)} visits to '
                    '${_grouped(counts.last)} paid customers',
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_platform),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, grow, _) => CustomPaint(
                    size: Size(
                      double.infinity,
                      _FunnelPainter.rowHeight * _stages.length,
                    ),
                    painter: _FunnelPainter(
                      counts: counts,
                      selected: _selected,
                      grow: grow,
                      scheme: scheme,
                      nameStyle: theme.textTheme.labelLarge!
                          .copyWith(color: scheme.onSurface),
                      valueStyle: theme.textTheme.labelMedium!
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
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
                  Text(_stages[_selected], style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Detail(
                        label: 'From previous',
                        value: '${fromPrevious.toStringAsFixed(1)}%',
                      ),
                      _Detail(
                        label: 'Of all visits',
                        value: '${overall.toStringAsFixed(1)}%',
                      ),
                      _Detail(label: 'Dropped', value: _grouped(lost)),
                    ],
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

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FunnelPainter extends CustomPainter {
  _FunnelPainter({
    required this.counts,
    required this.selected,
    required this.grow,
    required this.scheme,
    required this.nameStyle,
    required this.valueStyle,
  });

  static const rowHeight = 66.0;
  static const _labelHeight = 22.0;
  static const _barHeight = 22.0;

  final List<int> counts;
  final int selected;
  final double grow;
  final ColorScheme scheme;
  final TextStyle nameStyle;
  final TextStyle valueStyle;

  void _text(Canvas canvas, String text, TextStyle style, double y, double x,
      {bool end = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(end ? x - painter.width : x, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    double halfWidth(int i) => size.width / 2 * counts[i] / counts.first * grow;

    for (var i = 0; i < counts.length; i++) {
      final top = rowHeight * i;
      final barTop = top + _labelHeight;
      final half = halfWidth(i);
      final isSelected = i == selected;

      if (isSelected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, top, size.width, rowHeight - 4),
            const Radius.circular(8),
          ),
          Paint()..color = scheme.onSurface.withValues(alpha: 0.05),
        );
      }

      _text(canvas, _stages[i], nameStyle, top + 3, 6);
      _text(canvas, _grouped(counts[i]), valueStyle, top + 4, size.width - 6,
          end: true);

      // An ordered sequence, so the fill steps down one hue rather than
      // switching colours per stage.
      final strength = 1 - i / (counts.length - 1) * 0.55;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            center - half,
            barTop,
            center + half,
            barTop + _barHeight,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = scheme.primary.withValues(alpha: strength),
      );

      if (i == counts.length - 1) continue;

      // The wedge shows how much of this stage carries through to the next.
      final next = halfWidth(i + 1);
      final bottom = barTop + _barHeight + 2;
      final nextTop = rowHeight * (i + 1) + _labelHeight - 2;
      canvas.drawPath(
        Path()
          ..moveTo(center - half, bottom)
          ..lineTo(center + half, bottom)
          ..lineTo(center + next, nextTop)
          ..lineTo(center - next, nextTop)
          ..close(),
        Paint()..color = scheme.primary.withValues(alpha: 0.08),
      );
    }
  }

  @override
  bool shouldRepaint(_FunnelPainter old) =>
      old.counts != counts ||
      old.selected != selected ||
      old.grow != grow ||
      old.scheme != scheme;
}
