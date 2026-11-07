import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

// Picker data, not UI styling: these are the values a user can choose.
const _presets = <Color>[
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFFFDD835),
  Color(0xFF43A047),
  Color(0xFF00ACC1),
  Color(0xFF1E88E5),
  Color(0xFF5E35B1),
  Color(0xFFD81B60),
  Color(0xFF6D4C41),
  Color(0xFF546E7A),
];

const _hueStops = <Color>[
  Color(0xFFFF0000),
  Color(0xFFFFFF00),
  Color(0xFF00FF00),
  Color(0xFF00FFFF),
  Color(0xFF0000FF),
  Color(0xFFFF00FF),
  Color(0xFFFF0000),
];

String _hex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color? _parseHex(String input) {
  var text = input.trim().replaceFirst('#', '');
  if (text.length == 3) {
    text = text.split('').map((c) => '$c$c').join();
  }
  if (text.length != 6) return null;
  final value = int.tryParse(text, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

class HsvColorPicker extends StatefulWidget {
  /// Called with the color, including opacity, each time any control changes
  /// it. A drag fires this repeatedly.
  final ValueChanged<Color>? onColorChanged;

  const HsvColorPicker({super.key, this.onColorChanged});

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  // HSV is the source of truth. Round-tripping through RGB would lose the hue
  // whenever saturation or value reaches zero.
  var _hsv = HSVColor.fromColor(_presets[5]);
  final _hexController = TextEditingController(text: _hex(_presets[5]));
  final _hexFocus = FocusNode();
  final _recent = <Color>[];
  var _hexInvalid = false;

  Color get _color => _hsv.toColor();

  @override
  void dispose() {
    _hexController.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  void _setHsv(HSVColor value) {
    setState(() {
      _hsv = value;
      _hexInvalid = false;
      _hexController.text = _hex(value.toColor());
    });
    widget.onColorChanged?.call(_color);
  }

  void _setColor(Color color) {
    _hexFocus.unfocus();
    setState(() {
      _hsv = HSVColor.fromColor(color).withAlpha(_hsv.alpha);
      _hexInvalid = false;
      _hexController.text = _hex(color);
    });
    widget.onColorChanged?.call(_color);
  }

  void _onHexChanged(String text) {
    final parsed = _parseHex(text);
    setState(() {
      _hexInvalid = parsed == null;
      if (parsed != null) {
        _hsv = HSVColor.fromColor(parsed).withAlpha(_hsv.alpha);
      }
    });
    if (parsed != null) widget.onColorChanged?.call(_color);
  }

  void _commit() {
    final solid = _color.withValues(alpha: 1);
    setState(() {
      _recent
        ..remove(solid)
        ..insert(0, solid);
      if (_recent.length > 8) _recent.removeLast();
    });
    Clipboard.setData(ClipboardData(text: _hex(_color)));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Copied ${_hex(_color)} to the clipboard')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _color;
    final onColor = ThemeData.estimateBrightnessForColor(color.withValues(alpha: 1)) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(title: const Text('Brand color')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SaturationValueBox(hsv: _hsv, onChanged: _setHsv),
          const SizedBox(height: 16),
          _GradientSlider(
            label: 'Hue',
            value: _hsv.hue / 360,
            format: (t) => '${(t * 360).round()} degrees',
            thumbColor: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
            gradient: const LinearGradient(colors: _hueStops),
            onChanged: (t) => _setHsv(_hsv.withHue(t * 360)),
          ),
          const SizedBox(height: 12),
          _GradientSlider(
            label: 'Opacity',
            value: _hsv.alpha,
            format: _percent,
            thumbColor: color.withValues(alpha: 1),
            checkerboard: true,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0),
                color.withValues(alpha: 1),
              ],
            ),
            onChanged: (t) => _setHsv(_hsv.withAlpha(t)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: _hsv.alpha > 0.5
                    ? Text(
                        'Aa',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: onColor),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _hexController,
                  focusNode: _hexFocus,
                  onChanged: _onHexChanged,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Hex',
                    errorText: _hexInvalid ? 'Use #RGB or #RRGGBB' : null,
                    border: const OutlineInputBorder(),
                    suffixText: '${(_hsv.alpha * 100).round()}%',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _presets)
                _Swatch(
                  color: preset,
                  selected: _hex(preset) == _hex(color),
                  onTap: () => _setColor(preset),
                ),
            ],
          ),
          if (_recent.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recent',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final recent in _recent)
                  _Swatch(
                    color: recent,
                    selected: _hex(recent) == _hex(color),
                    onTap: () => _setColor(recent),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _commit,
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Use this color'),
          ),
        ],
      ),
    );
  }
}

String _percent(double t) => '${(t * 100).round()}%';

// One arrow key press, and the larger step a screen reader action takes.
const _keyStep = 0.01;
const _semanticStep = 0.05;

/// Makes a custom-painted control a tab stop with arrow keys and a focus ring.
///
/// [onArrow] gets +1 or -1 on one axis: dx for right and left, dy for up and
/// down. [builder] receives a callback that moves focus here on a pointer tap.
class _KeyboardControl extends StatelessWidget {
  const _KeyboardControl({
    required this.radius,
    required this.onArrow,
    required this.builder,
  });

  final double radius;
  final void Function(int dx, int dy) onArrow;
  final Widget Function(VoidCallback requestFocus) builder;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) {
        if (event is KeyUpEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.arrowRight) {
          onArrow(1, 0);
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          onArrow(-1, 0);
        } else if (key == LogicalKeyboardKey.arrowUp) {
          onArrow(0, 1);
        } else if (key == LogicalKeyboardKey.arrowDown) {
          onArrow(0, -1);
        } else {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: Builder(
        builder: (context) {
          final node = Focus.of(context);
          return Container(
            foregroundDecoration: node.hasFocus
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  )
                : null,
            child: builder(node.requestFocus),
          );
        },
      ),
    );
  }
}

class _SaturationValueBox extends StatelessWidget {
  const _SaturationValueBox({required this.hsv, required this.onChanged});

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  void _adjust({double saturation = 0, double value = 0}) {
    onChanged(
      hsv
          .withSaturation((hsv.saturation + saturation).clamp(0.0, 1.0))
          .withValue((hsv.value + value).clamp(0.0, 1.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String describe(double value) =>
        'Brightness ${_percent(value)}, '
        'saturation ${_percent(hsv.saturation)}';

    // One axis fits the slider actions, so saturation uses custom actions.
    return Semantics(
      container: true,
      slider: true,
      label: 'Saturation and brightness',
      value: describe(hsv.value),
      increasedValue: describe((hsv.value + _semanticStep).clamp(0.0, 1.0)),
      decreasedValue: describe((hsv.value - _semanticStep).clamp(0.0, 1.0)),
      onIncrease: hsv.value < 1 ? () => _adjust(value: _semanticStep) : null,
      onDecrease: hsv.value > 0 ? () => _adjust(value: -_semanticStep) : null,
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Increase saturation'): () =>
            _adjust(saturation: _semanticStep),
        const CustomSemanticsAction(label: 'Decrease saturation'): () =>
            _adjust(saturation: -_semanticStep),
      },
      child: _KeyboardControl(
        radius: 12,
        onArrow: (dx, dy) =>
            _adjust(saturation: dx * _keyStep, value: dy * _keyStep),
        builder: (requestFocus) => SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              void update(Offset position) {
                requestFocus();
                onChanged(
                  hsv
                      .withSaturation(
                        (position.dx / size.width).clamp(0.0, 1.0),
                      )
                      .withValue(
                        1 - (position.dy / size.height).clamp(0.0, 1.0),
                      ),
                );
              }

              // The Semantics above owns the actions. The defaults here would
              // replay a tap or drag at the box's top-left corner.
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTapDown: (d) => update(d.localPosition),
                onPanStart: (d) => update(d.localPosition),
                onPanUpdate: (d) => update(d.localPosition),
                child: CustomPaint(
                  size: size,
                  painter: _SvPainter(hsv: hsv),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SvPainter extends CustomPainter {
  _SvPainter({required this.hsv});

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.save();
    canvas.clipRRect(rounded);

    final pure = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(colors: [Colors.white, pure])
            .createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );
    canvas.restore();

    final thumb = Offset(
      hsv.saturation * size.width,
      (1 - hsv.value) * size.height,
    );
    canvas.drawCircle(
      thumb,
      10,
      Paint()..color = hsv.withAlpha(1).toColor(),
    );
    canvas.drawCircle(
      thumb,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white,
    );
    canvas.drawCircle(
      thumb,
      11.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black26,
    );
  }

  @override
  bool shouldRepaint(_SvPainter old) => old.hsv != hsv;
}

class _GradientSlider extends StatelessWidget {
  const _GradientSlider({
    required this.label,
    required this.value,
    required this.format,
    required this.thumbColor,
    required this.gradient,
    required this.onChanged,
    this.checkerboard = false,
  });

  final String label;
  final double value;
  final String Function(double value) format;
  final Color thumbColor;
  final Gradient gradient;
  final ValueChanged<double> onChanged;
  final bool checkerboard;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final up = (value + _semanticStep).clamp(0.0, 1.0);
    final down = (value - _semanticStep).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      slider: true,
      label: label,
      value: format(value),
      increasedValue: format(up),
      decreasedValue: format(down),
      onIncrease: value < 1 ? () => onChanged(up) : null,
      onDecrease: value > 0 ? () => onChanged(down) : null,
      child: _KeyboardControl(
        radius: 14,
        onArrow: (dx, dy) =>
            onChanged((value + (dx + dy) * _keyStep).clamp(0.0, 1.0)),
        builder: (requestFocus) => SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              void update(double dx) {
                requestFocus();
                onChanged((dx / width).clamp(0.0, 1.0));
              }

              // The Semantics above owns the actions. The defaults here would
              // replay a tap or drag at the track's left edge.
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTapDown: (d) => update(d.localPosition.dx),
                onHorizontalDragStart: (d) => update(d.localPosition.dx),
                onHorizontalDragUpdate: (d) => update(d.localPosition.dx),
                child: CustomPaint(
                  size: Size(width, 28),
                  painter: _TrackPainter(
                    value: value,
                    gradient: gradient,
                    thumbColor: thumbColor,
                    checkerboard: checkerboard,
                    checkLight: scheme.surfaceContainerLowest,
                    checkDark: scheme.surfaceContainerHighest,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.value,
    required this.gradient,
    required this.thumbColor,
    required this.checkerboard,
    required this.checkLight,
    required this.checkDark,
  });

  final double value;
  final Gradient gradient;
  final Color thumbColor;
  final bool checkerboard;
  final Color checkLight;
  final Color checkDark;

  @override
  void paint(Canvas canvas, Size size) {
    const trackHeight = 14.0;
    final rect = Rect.fromLTWH(
      0,
      (size.height - trackHeight) / 2,
      size.width,
      trackHeight,
    );
    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(7));

    canvas.save();
    canvas.clipRRect(rounded);
    if (checkerboard) {
      const cell = 7.0;
      final light = Paint()..color = checkLight;
      final dark = Paint()..color = checkDark;
      canvas.drawRect(rect, light);
      for (var col = 0; col * cell < size.width; col++) {
        for (var row = 0; row < 2; row++) {
          if ((col + row).isEven) {
            canvas.drawRect(
              Rect.fromLTWH(col * cell, rect.top + row * cell, cell, cell),
              dark,
            );
          }
        }
      }
    }
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    canvas.restore();

    final thumb = Offset(
      (value * size.width).clamp(10.0, size.width - 10),
      size.height / 2,
    );
    canvas.drawCircle(thumb, 10, Paint()..color = thumbColor);
    canvas.drawCircle(
      thumb,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white,
    );
    canvas.drawCircle(
      thumb,
      11.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black26,
    );
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.value != value ||
      old.thumbColor != thumbColor ||
      old.gradient != gradient ||
      old.checkLight != checkLight;
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: _hex(color),
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.onSurface : scheme.outlineVariant,
              width: selected ? 2.5 : 1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
      ),
    );
  }
}
