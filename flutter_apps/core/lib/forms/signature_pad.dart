import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class _Point {
  const _Point(this.position, this.width);

  final Offset position;
  final double width;
}

class _Stroke {
  _Stroke(this.color);

  final Color color;
  final points = <_Point>[];
}

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final _boundary = GlobalKey();
  final _strokes = <_Stroke>[];

  /// Bumped on every change, because the stroke list is mutated in place.
  final _revision = ValueNotifier<int>(0);

  var _penSize = 3.0;
  var _inkIndex = 0;
  Offset? _lastPosition;
  Duration? _lastTime;
  double? _lastWidth;
  Uint8List? _saved;

  bool get _hasInk => _strokes.isNotEmpty;

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  void _beginStroke(DragStartDetails details, Color ink) {
    final stroke = _Stroke(ink)
      ..points.add(_Point(details.localPosition, _penSize));
    _lastPosition = details.localPosition;
    _lastTime = details.sourceTimeStamp;
    _lastWidth = _penSize;
    final hadInk = _hasInk;
    _strokes.add(stroke);
    _revision.value++;
    if (!hadInk) setState(() {});
  }

  /// Faster movement thins the line, which is what makes it look like ink.
  void _extendStroke(DragUpdateDetails details) {
    final last = _lastPosition;
    if (last == null) return;
    final distance = (details.localPosition - last).distance;
    if (distance < 1) return;

    final now = details.sourceTimeStamp;
    final elapsed = now != null && _lastTime != null
        ? (now - _lastTime!).inMicroseconds / 1000
        : 16.0;
    final speed = distance / math.max(elapsed, 1);
    final target = (_penSize * (1.5 - speed * 0.45))
        .clamp(_penSize * 0.45, _penSize * 1.5);
    // Low-pass filter so the width never visibly jumps between segments.
    final width = _lastWidth! * 0.7 + target * 0.3;

    _strokes.last.points.add(_Point(details.localPosition, width));
    _lastPosition = details.localPosition;
    _lastTime = now;
    _lastWidth = width;
    _revision.value++;
  }

  void _undo() {
    setState(() => _strokes.removeLast());
    _revision.value++;
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _saved = null;
    });
    _revision.value++;
  }

  Future<void> _save() async {
    final boundary = _boundary.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null || !mounted) return;
    setState(() => _saved = data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inks = [scheme.onSurface, scheme.primary, scheme.tertiary];
    const inkNames = ['Standard', 'Primary', 'Tertiary'];
    final saved = _saved;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign document'),
        actions: [
          IconButton(
            tooltip: 'Undo stroke',
            onPressed: _hasInk ? _undo : null,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: _hasInk ? _clear : null,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      // No scroll view here: it would compete with the pad for vertical drags.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _boundary,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => _beginStroke(d, inks[_inkIndex]),
                      onPanUpdate: _extendStroke,
                      child: CustomPaint(
                        painter: _SignaturePainter(
                          strokes: _strokes,
                          revision: _revision,
                          background: scheme.surfaceContainerLow,
                          guide: scheme.outline,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < inks.length; i++)
                    _InkSwatch(
                      name: '${inkNames[i]} ink',
                      color: inks[i],
                      selected: i == _inkIndex,
                      onTap: () => setState(() => _inkIndex = i),
                    ),
                  const SizedBox(width: 4),
                  Icon(Icons.line_weight,
                      size: 18, color: scheme.onSurfaceVariant),
                  Expanded(
                    child: Slider(
                      min: 1.5,
                      max: 6,
                      value: _penSize,
                      label: 'Pen size',
                      onChanged: (v) => setState(() => _penSize = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (saved != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 96,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Image.memory(saved, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Saved PNG, ${(saved.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              FilledButton(
                onPressed: _hasInk ? _save : null,
                child: const Text('Save signature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InkSwatch extends StatelessWidget {
  const _InkSwatch({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: name,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 3 : 1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.revision,
    required this.background,
    required this.guide,
  }) : super(repaint: revision);

  final List<_Stroke> strokes;
  final ValueNotifier<int> revision;
  final Color background;
  final Color guide;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final lineY = size.height * 0.72;
    canvas.drawLine(
      Offset(24, lineY),
      Offset(size.width - 24, lineY),
      Paint()
        ..color = guide
        ..strokeWidth = 1,
    );
    final cross = Paint()
      ..color = guide
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(24, lineY - 16),
      Offset(34, lineY - 6),
      cross,
    );
    canvas.drawLine(
      Offset(34, lineY - 16),
      Offset(24, lineY - 6),
      cross,
    );

    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final points = stroke.points;

      if (points.length == 1) {
        canvas.drawCircle(
          points.first.position,
          points.first.width / 2,
          Paint()..color = stroke.color,
        );
        continue;
      }

      // Each segment curves through the midpoints of its neighbours, so a
      // sparse pointer stream still reads as a smooth line.
      var start = points.first.position;
      for (var i = 1; i < points.length; i++) {
        final control = points[i - 1].position;
        final end = i == points.length - 1
            ? points[i].position
            : (control + points[i].position) / 2;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
        canvas.drawPath(path, paint..strokeWidth = points[i].width);
        start = end;
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.background != background || old.guide != guide;
}
