import 'package:flutter/material.dart';

import '../models/password_strength.dart';
import 'key_mark.dart';

/// Live password feedback. The key grows a tooth per strength level, with the
/// level also written out and each rule listed, so color is never the only
/// signal.
class StrengthKey extends StatelessWidget {
  const StrengthKey({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final score = strength.score;
    final color = switch (score) {
      0 => scheme.outline,
      1 => scheme.error,
      2 => scheme.tertiary,
      _ => scheme.primary,
    };
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: score.toDouble()),
              duration: duration,
              curve: Curves.easeOutBack,
              builder: (context, value, _) {
                return KeyMark(
                  color: scheme.onSurfaceVariant,
                  toothColor: color,
                  socketColor: scheme.surfaceContainerHighest,
                  height: 34,
                  teeth: [
                    for (var i = 0; i < 4; i++)
                      (value - i).clamp(0.0, 1.0) * (0.55 + 0.15 * i),
                  ],
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                liveRegion: true,
                label: 'Password strength: ${strength.label}',
                excludeSemantics: true,
                child: Text(
                  strength.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final rule in strength.rules)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Semantics(
              label: '${rule.label}: ${rule.passed ? 'met' : 'not met'}',
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    rule.passed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: rule.passed ? scheme.primary : scheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
