import 'package:flutter/material.dart';

import '../models/auth_failure.dart';

/// Shows a failed request inside the form that sent it.
class FormBanner extends StatelessWidget {
  const FormBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// A banner for [failure], with [onRetry] offered when retrying could help.
  factory FormBanner.failure(AuthFailure failure, {VoidCallback? onRetry}) {
    return FormBanner(
      message: failure.message,
      actionLabel: failure.isRetryable && onRetry != null ? 'Try again' : null,
      onAction: failure.isRetryable ? onRetry : null,
    );
  }

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: scheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
              if (actionLabel != null)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onErrorContainer,
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The main button of a form. Stays in place with a spinner during a request.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.busyLabel,
    required this.isBusy,
    required this.onPressed,
    this.isDanger = false,
  });

  final String label;
  final String busyLabel;
  final bool isBusy;
  final VoidCallback onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isBusy ? null : onPressed,
        style: isDanger
            ? FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              )
            : null,
        child: isBusy
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                  const SizedBox(width: 10),
                  Flexible(child: Text(busyLabel, textAlign: TextAlign.center)),
                ],
              )
            : Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Text with a link after it, wrapping onto two lines when space is short.
class PromptLink extends StatelessWidget {
  const PromptLink({
    super.key,
    required this.prompt,
    required this.label,
    required this.onPressed,
  });

  final String prompt;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        TextButton(onPressed: onPressed, child: Text(label)),
      ],
    );
  }
}

/// Moves focus to the first field that failed validation.
void focusFirstInvalid(List<(FocusNode, bool)> fields) {
  for (final (node, isValid) in fields) {
    if (!isValid) {
      node.requestFocus();
      return;
    }
  }
}
