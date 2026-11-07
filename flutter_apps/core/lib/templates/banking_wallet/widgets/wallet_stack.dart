import 'package:flutter/material.dart';

import '../models/account.dart';
import 'money_text.dart';
import 'stitched_panel.dart';

/// The home screen's centerpiece: each account is a slip sticking out of a
/// billfold, and the front pocket holds the total balance.
class WalletStack extends StatelessWidget {
  const WalletStack({
    super.key,
    required this.accounts,
    required this.pocket,
    required this.pocketHeight,
    required this.onAccountTap,
  });

  final List<Account> accounts;

  /// The content of the front pocket.
  final Widget pocket;
  final double pocketHeight;
  final ValueChanged<Account> onAccountTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
    final peek = 58.0 * textScale;
    final pocketTop = accounts.length * peek;
    final scaledPocket = pocketHeight * textScale;

    return SizedBox(
      height: pocketTop + scaledPocket,
      child: Stack(
        children: [
          for (var i = 0; i < accounts.length; i++)
            Positioned(
              top: i * peek,
              left: (accounts.length - i) * 5.0,
              right: (accounts.length - i) * 5.0,
              height: peek + 34,
              child: _SlideOutOfPocket(
                distance: pocketTop - i * peek,
                index: i,
                child: _AccountSlip(
                  account: accounts[i],
                  index: i,
                  height: peek,
                  onTap: () => onAccountTap(accounts[i]),
                ),
              ),
            ),
          Positioned(
            top: pocketTop,
            left: 0,
            right: 0,
            height: scaledPocket,
            child: StitchedPanel(child: pocket),
          ),
        ],
      ),
    );
  }
}

/// Plays once when the wallet first appears.
class _SlideOutOfPocket extends StatelessWidget {
  const _SlideOutOfPocket({
    required this.distance,
    required this.index,
    required this.child,
  });

  final double distance;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: Duration(milliseconds: 420 + index * 110),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * distance),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _AccountSlip extends StatelessWidget {
  const _AccountSlip({
    required this.account,
    required this.index,
    required this.height,
    required this.onTap,
  });

  final Account account;
  final int index;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (index % 3) {
      0 => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      1 => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };

    return Material(
      color: background,
      elevation: 1,
      shadowColor: scheme.shadow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${account.kind.label}  ${account.mask}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: foreground.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedMoneyText(
                    account.balanceCents,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
