import 'package:flutter/material.dart';

import '../models/payee.dart';

class PayeeAvatar extends StatelessWidget {
  const PayeeAvatar({super.key, required this.payee, this.size = 44});

  final Payee payee;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (payee.name.length % 3) {
      0 => (scheme.primaryContainer, scheme.onPrimaryContainer),
      1 => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _ => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: payee.isOwnAccount
          ? Icon(Icons.savings_outlined, size: size * 0.5, color: foreground)
          : Text(
              payee.initials,
              textScaler: TextScaler.noScaling,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
