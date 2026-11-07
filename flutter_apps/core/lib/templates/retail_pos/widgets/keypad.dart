import 'package:flutter/material.dart';

import 'pos_theme.dart';

/// Cash register keypad. Digits fill from the right, so `1`, `2`, `5`, `0`
/// reads as `$12.50` with no decimal key to miss.
class Keypad extends StatelessWidget {
  const Keypad({
    super.key,
    required this.onDigits,
    required this.onBackspace,
    this.keyHeight = 56,
  });

  final ValueChanged<String> onDigits;
  final VoidCallback onBackspace;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    Widget digit(String value) => _Key(
      height: keyHeight,
      semanticLabel: value,
      onTap: () => onDigits(value),
      child: Text(
        value,
        style: Theme.of(context).textTheme.titleLarge!.tabular,
      ),
    );

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: digit(row[0])),
                const SizedBox(width: 6),
                Expanded(child: digit(row[1])),
                const SizedBox(width: 6),
                Expanded(child: digit(row[2])),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(child: digit('00')),
            const SizedBox(width: 6),
            Expanded(child: digit('0')),
            const SizedBox(width: 6),
            Expanded(
              child: _Key(
                height: keyHeight,
                semanticLabel: 'Backspace',
                onTap: onBackspace,
                child: const Icon(Icons.backspace_outlined, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.height,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final double height;
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
