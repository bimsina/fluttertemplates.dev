import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 3x4 keypad used for both the PIN and amount entry. Fills the height it is
/// given, and accepts a hardware keyboard as well.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKey,
    required this.onBackspace,
    this.allowDecimal = false,
    this.enabled = true,
  });

  /// Called with `0` to `9`, or `.` when [allowDecimal] is true.
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final bool allowDecimal;
  final bool enabled;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      onBackspace();
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character == null) return KeyEventResult.ignored;
    final isDigit = RegExp(r'^[0-9]$').hasMatch(character);
    if (isDigit || (allowDecimal && character == '.')) {
      onKey(character);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _press(String key) {
    HapticFeedback.selectionClick();
    onKey(key);
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        children: [
          for (final row in rows)
            Expanded(
              child: Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: _Key(
                        label: key,
                        onTap: enabled ? () => _press(key) : null,
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: allowDecimal
                      ? _Key(
                          label: '.',
                          onTap: enabled ? () => _press('.') : null,
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: _Key(
                    label: '0',
                    onTap: enabled ? () => _press('0') : null,
                  ),
                ),
                Expanded(
                  child: _Key(
                    icon: Icons.backspace_outlined,
                    semanticLabel: 'Delete',
                    onTap: enabled ? onBackspace : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, this.semanticLabel, required this.onTap});

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDigit = label != null;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: isDigit ? scheme.surfaceContainerLow : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: isDigit
                ? FittedBox(
                    child: Text(
                      label!,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    semanticLabel: semanticLabel,
                    color: scheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}
