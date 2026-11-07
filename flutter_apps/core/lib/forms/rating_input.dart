import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _labels = <double, String>{
  0.5: 'Awful',
  1.0: 'Very poor',
  1.5: 'Poor',
  2.0: 'Below average',
  2.5: 'Average',
  3.0: 'Decent',
  3.5: 'Good',
  4.0: 'Very good',
  4.5: 'Excellent',
  5.0: 'Outstanding',
};

const _aspects = ['Cleanliness', 'Communication', 'Value'];

class RatingInput extends StatefulWidget {
  const RatingInput({super.key});

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  final _comment = TextEditingController();
  final _aspectRatings = {for (final a in _aspects) a: 0.0};
  var _overall = 0.0;
  var _submitted = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate your stay')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_submitted)
            _Summary(
              overall: _overall,
              aspects: _aspectRatings,
              comment: _comment.text.trim(),
              onEdit: () => setState(() => _submitted = false),
            )
          else ...[
            Text(
              'How was it overall?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: _StarRating(
                value: _overall,
                size: 44,
                label: 'Overall rating',
                onChanged: (v) => setState(() => _overall = v),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: Text(
                _labels[_overall] ?? 'Tap, drag or use arrow keys',
                key: ValueKey(_overall),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 24),
            for (final aspect in _aspects)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        aspect,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    _StarRating(
                      value: _aspectRatings[aspect]!,
                      size: 26,
                      label: '$aspect rating',
                      onChanged: (v) =>
                          setState(() => _aspectRatings[aspect] = v),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _comment,
              minLines: 3,
              maxLines: 5,
              maxLength: 280,
              decoration: const InputDecoration(
                labelText: 'Anything to add? (optional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _overall == 0
                  ? null
                  : () => setState(() => _submitted = true),
              child: const Text('Submit review'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Half-star input. Pointer position is snapped to 0.5 steps; hovering previews
/// the value, tapping or dragging sets it, and tapping the same value clears it.
class _StarRating extends StatefulWidget {
  const _StarRating({
    required this.value,
    required this.size,
    required this.label,
    required this.onChanged,
  });

  final double value;
  final double size;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  State<_StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<_StarRating> {
  static const _stars = 5;

  double? _preview;
  var _focused = false;

  double _snap(double dx) {
    final raw = dx / widget.size;
    return ((raw * 2).ceil() / 2).clamp(0.5, _stars.toDouble());
  }

  void _step(double by) {
    widget.onChanged((widget.value + by).clamp(0.0, _stars.toDouble()));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp) {
      _step(0.5);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown) {
      _step(-0.5);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = _preview ?? widget.value;

    return Semantics(
      slider: true,
      label: widget.label,
      value: '${widget.value} of $_stars',
      increasedValue: '${widget.value + 0.5} of $_stars',
      decreasedValue: '${widget.value - 0.5} of $_stars',
      onIncrease: () => _step(0.5),
      onDecrease: () => _step(-0.5),
      child: Focus(
        onKeyEvent: _onKey,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => setState(() => _preview = _snap(e.localPosition.dx)),
          onExit: (_) => setState(() => _preview = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final value = _snap(d.localPosition.dx);
              widget.onChanged(value == widget.value ? 0 : value);
            },
            onHorizontalDragUpdate: (d) =>
                widget.onChanged(_snap(d.localPosition.dx)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _focused ? scheme.primary : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _stars; i++)
                    _Star(
                      fill: (shown - i).clamp(0.0, 1.0),
                      size: widget.size,
                      color: scheme.primary,
                      track: scheme.outlineVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.fill,
    required this.size,
    required this.color,
    required this.track,
  });

  final double fill;
  final double size;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Icon(Icons.star_rounded, size: size, color: track),
          ClipRect(
            clipper: _FractionClipper(fill),
            child: Icon(Icons.star_rounded, size: size, color: color),
          ),
        ],
      ),
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  _FractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper old) => old.fraction != fraction;
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.overall,
    required this.aspects,
    required this.comment,
    required this.onEdit,
  });

  final double overall;
  final Map<String, double> aspects;
  final String comment;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rated = aspects.entries.where((e) => e.value > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, size: 48, color: scheme.primary),
        const SizedBox(height: 8),
        Text(
          'Thanks for your review',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '$overall out of 5, ${(_labels[overall] ?? '').toLowerCase()}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        for (final entry in rated)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 112,
                  child: Text(entry.key, style: theme.textTheme.bodySmall),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: entry.value / 5,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entry.value}', style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('"$comment"', style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onEdit, child: const Text('Edit review')),
      ],
    );
  }
}
