import 'package:flutter/material.dart';

import 'pos_theme.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.max,
    this.min = 0,
    this.label = 'quantity',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int? max;
  final int min;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atMax = max != null && value >= max!;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease $label',
            onPressed: value <= min ? null : () => onChanged(value - 1),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 24),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall!.tabular,
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase $label',
            onPressed: atMax ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 18),
    tooltip: tooltip,
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
    padding: EdgeInsets.zero,
  );
}
