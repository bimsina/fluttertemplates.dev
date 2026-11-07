import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Drag the thumb to the end to confirm. Harder to trigger by accident than a
/// button, which is what you want for moving money. Screen readers get a plain
/// tap action instead, and keyboards can focus it and press Enter or Space.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.busy = false,
  });

  final String label;
  final VoidCallback onConfirmed;

  /// While true the thumb stays at the end with a spinner. When it goes back
  /// to false, as it does after a failure, the thumb returns to the start.
  final bool busy;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with SingleTickerProviderStateMixin {
  static const double _trackHeight = 64;
  static const double _thumbSize = 54;
  static const double _inset = 5;
  static const double _confirmAt = 0.85;

  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  bool _hasFocus = false;

  @override
  void didUpdateWidget(SlideToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busy && !widget.busy) _position.animateBack(0);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double travel) {
    if (widget.busy) return;
    _position.value += details.primaryDelta! / travel;
  }

  void _onDragEnd() {
    if (widget.busy) return;
    if (_position.value >= _confirmAt) {
      _confirm();
    } else {
      _position.animateBack(0);
    }
  }

  void _confirm() {
    if (widget.busy) return;
    _position.animateTo(1);
    widget.onConfirmed();
  }

  /// Handled here rather than through `ActivateIntent`, because the default
  /// shortcuts bind Enter to a different intent on the web. A held key
  /// repeats, and must not confirm twice or carry over from the last screen.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    final isActivationKey =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space;
    if (!isActivationKey) return KeyEventResult.ignored;
    if (event is KeyDownEvent) _confirm();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      button: true,
      enabled: !widget.busy,
      label: widget.label,
      onTap: widget.busy ? null : _confirm,
      child: Focus(
        onKeyEvent: _onKeyEvent,
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final travel = constraints.maxWidth - _thumbSize - _inset * 2;
              return SizedBox(
                height: _trackHeight,
                child: AnimatedBuilder(
                  animation: _position,
                  builder: (context, _) {
                    final left = _inset + travel * _position.value;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: left + _thumbSize + _inset,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          left: _thumbSize + _inset * 2,
                          right: 12,
                          child: Center(
                            child: Opacity(
                              opacity: (1 - _position.value * 1.4).clamp(0, 1),
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: left,
                          top: _inset,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) =>
                                _onDragUpdate(details, travel),
                            onHorizontalDragEnd: (_) => _onDragEnd(),
                            onHorizontalDragCancel: _onDragEnd,
                            child: MouseRegion(
                              cursor: widget.busy
                                  ? SystemMouseCursors.basic
                                  : SystemMouseCursors.grab,
                              child: Container(
                                width: _thumbSize,
                                height: _thumbSize,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: widget.busy
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: scheme.onPrimary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.arrow_forward,
                                        color: scheme.onPrimary,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        if (_hasFocus)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: scheme.primary,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
