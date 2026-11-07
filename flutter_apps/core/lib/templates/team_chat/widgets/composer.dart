import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/message.dart';
import 'chat_style.dart';

class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.initialText,
    required this.hintText,
    required this.focusNode,
    required this.onChanged,
    required this.onSend,
    required this.onCancelReply,
    this.replyTo,
    this.replyToLabel,
  });

  final String initialText;
  final String hintText;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSend;
  final VoidCallback onCancelReply;
  final Message? replyTo;
  final String? replyToLabel;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  bool get _canSend => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.focusNode.onKeyEvent = _onKey;
  }

  /// Picks up text the store puts back, such as a failed message being edited.
  /// While typing the two already match, so this leaves the cursor alone.
  @override
  void didUpdateWidget(Composer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText != _controller.text) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    widget.focusNode.onKeyEvent = null;
    _controller.dispose();
    super.dispose();
  }

  /// Enter sends and Shift+Enter adds a line, on hardware keyboards.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (event is! KeyDownEvent ||
        !isEnter ||
        HardwareKeyboard.instance.isShiftPressed ||
        _controller.value.composing.isValid) {
      return KeyEventResult.ignored;
    }
    _send();
    return KeyEventResult.handled;
  }

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text);
    _controller.clear();
    setState(() {});
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final replyTo = widget.replyTo;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.bottomCenter,
                child: replyTo == null
                    ? const SizedBox(width: double.infinity)
                    : _ReplyPreview(
                        message: replyTo,
                        label: widget.replyToLabel ?? '',
                        onCancel: widget.onCancelReply,
                      ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: widget.focusNode,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        height: 1.3,
                      ),
                      onChanged: (text) {
                        widget.onChanged(text);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintMaxLines: 1,
                        isDense: true,
                        filled: true,
                        fillColor: scheme.raised,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(21),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendButton(enabled: _canSend, onPressed: _send),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 42,
      height: 42,
      decoration: ShapeDecoration(
        color: enabled ? scheme.primary : scheme.raised,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: IconButton(
        tooltip: 'Send',
        padding: EdgeInsets.zero,
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          Icons.arrow_upward_rounded,
          size: 22,
          color: enabled
              ? scheme.onPrimary
              : scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({
    required this.message,
    required this.label,
    required this.onCancel,
  });

  final Message message;
  final String label;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            margin: const EdgeInsets.only(left: 6, right: 10),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  message.text.replaceAll('\n', ' '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancel reply',
            onPressed: onCancel,
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
