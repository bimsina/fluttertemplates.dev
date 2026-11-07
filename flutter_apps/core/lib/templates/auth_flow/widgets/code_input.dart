import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Six boxes backed by one real text field, so paste, SMS and email autofill,
/// backspace and screen readers all work as they would on a plain input.
class CodeInput extends StatelessWidget {
  const CodeInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.length = 6,
    this.isEnabled = true,
    this.hasError = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCompleted;
  final int length;
  final bool isEnabled;
  final bool hasError;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.textScalerOf(context).scale(60);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: ListenableBuilder(
              listenable: Listenable.merge([controller, focusNode]),
              builder: (context, _) => _Cells(
                text: controller.text,
                length: length,
                hasFocus: focusNode.hasFocus,
                hasError: hasError,
              ),
            ),
          ),
          // Invisible, but it receives every tap and keystroke.
          TextSelectionTheme(
            data: const TextSelectionThemeData(
              selectionColor: Colors.transparent,
            ),
            child: Semantics(
              label: '$length digit verification code',
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isEnabled,
                autofocus: autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                showCursor: false,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration.collapsed(hintText: ''),
                onChanged: (value) {
                  if (value.length == length) onCompleted();
                },
                onSubmitted: (value) {
                  if (value.length == length) onCompleted();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cells extends StatelessWidget {
  const _Cells({
    required this.text,
    required this.length,
    required this.hasFocus,
    required this.hasError,
  });

  final String text;
  final int length;
  final bool hasFocus;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Builder(
              builder: (context) {
                final isActive =
                    hasFocus &&
                    (i == text.length ||
                        (i == length - 1 && text.length == length));
                final Color border;
                if (hasError) {
                  border = scheme.error;
                } else if (isActive) {
                  border = scheme.primary;
                } else {
                  border = scheme.outline;
                }
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: i < text.length
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: border,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      i < text.length ? text[i] : '',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
