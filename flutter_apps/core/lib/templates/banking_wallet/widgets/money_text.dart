import 'package:flutter/material.dart';

import '../models/formatting.dart';
import '../state/wallet_scope.dart';
import 'wallet_theme.dart';

const String _hiddenAmount = r'$ ••••';

/// An amount of money that honors the "hide balances" switch.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.cents, {
    super.key,
    this.style,
    this.signed = false,
    this.decimals = true,
    this.textAlign,
  });

  final int cents;
  final TextStyle? style;
  final bool signed;
  final bool decimals;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final hidden = WalletScope.of(context).balancesHidden;
    return Text(
      hidden
          ? _hiddenAmount
          : formatCents(cents, signed: signed, decimals: decimals),
      maxLines: 1,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: (style ?? const TextStyle()).copyWith(
        fontFeatures: tabularFigures,
      ),
    );
  }
}

/// A [MoneyText] that counts to its new value when [cents] changes, so a
/// finished transfer is visible on the balance itself.
class AnimatedMoneyText extends StatelessWidget {
  const AnimatedMoneyText(this.cents, {super.key, this.style});

  final int cents;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: cents.toDouble()),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        // Display only. The real amount is still the integer in [cents].
        return MoneyText(value.round(), style: style);
      },
    );
  }
}
