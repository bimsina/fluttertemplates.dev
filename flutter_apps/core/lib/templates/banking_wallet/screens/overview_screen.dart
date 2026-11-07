import 'package:flutter/material.dart';

import '../models/payee.dart';
import '../state/spending_insights.dart';
import '../state/wallet_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/money_text.dart';
import '../widgets/payee_avatar.dart';
import '../widgets/stale_data_notice.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_stack.dart';
import '../widgets/wallet_theme.dart';
import 'account_detail_screen.dart';
import 'send/amount_screen.dart';
import 'transaction_detail_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({
    super.key,
    required this.onSeeAllActivity,
    required this.onOpenSend,
  });

  final VoidCallback onSeeAllActivity;
  final VoidCallback onOpenSend;

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= twoColumnBreakpoint;
        final wallets = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WalletStack(
              accounts: wallet.accounts,
              pocketHeight: 182,
              pocket: _Pocket(onOpenSend: onOpenSend),
              onAccountTap: (account) => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AccountDetailScreen(accountId: account.id),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SendAgainRow(),
          ],
        );
        final recent = _RecentActivity(
          limit: twoColumns ? 8 : 5,
          onSeeAll: onSeeAllActivity,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: twoColumns ? 1040 : 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Greeting(),
                  const StaleDataNotice(),
                  if (wallet.isDataStale) const SizedBox(height: 12),
                  if (twoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: wallets),
                        const SizedBox(width: 28),
                        Expanded(child: recent),
                      ],
                    )
                  else ...[
                    wallets,
                    const SizedBox(height: 18),
                    recent,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  String _partOfDay(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = WalletScope.of(context);
    final hidden = wallet.balancesHidden;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _partOfDay(DateTime.now()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  wallet.customer?.firstName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hidden ? 'Show balances' : 'Hide balances',
            icon: Icon(
              hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: wallet.toggleBalancesHidden,
          ),
          IconButton(
            tooltip: 'Lock',
            icon: const Icon(Icons.lock_outline),
            onPressed: wallet.lock,
          ),
        ],
      ),
    );
  }
}

/// The front of the wallet: total balance, this month's flow, and Send.
class _Pocket extends StatelessWidget {
  const _Pocket({required this.onOpenSend});

  final VoidCallback onOpenSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wallet = WalletScope.of(context);
    final flow = monthCashFlow(wallet.transactions, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total balance',
          maxLines: 1,
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AnimatedMoneyText(
                wallet.totalBalanceCents,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _FlowStat(
                icon: Icons.south_west,
                label: 'In',
                cents: flow.inCents,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FlowStat(
                icon: Icons.north_east,
                label: 'Out',
                cents: flow.outCents,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.onPrimary,
                foregroundColor: scheme.primary,
                minimumSize: const Size(76, 46),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: onOpenSend,
              child: const Text('Send'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlowStat extends StatelessWidget {
  const _FlowStat({
    required this.icon,
    required this.label,
    required this.cents,
  });

  final IconData icon;
  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        MoneyText(
          cents,
          decimals: false,
          style: theme.textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _SendAgainRow extends StatelessWidget {
  const _SendAgainRow();

  void _open(BuildContext context, Payee payee) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => AmountScreen(payee: payee)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payees = WalletScope.of(context).recentPayees.take(6).toList();
    if (payees.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Send again', style: theme.textTheme.titleMedium),
        ),
        SizedBox(
          height: 82 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: payees.length,
            separatorBuilder: (_, _) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final payee = payees[index];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _open(context, payee),
                child: SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PayeeAvatar(payee: payee, size: 46),
                      const SizedBox(height: 6),
                      Text(
                        payee.name.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.limit, required this.onSeeAll});

  final int limit;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = WalletScope.of(context);
    final recent = wallet.transactions.take(limit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('Recent', style: theme.textTheme.titleMedium),
              ),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        if (recent.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message: 'Payments and transfers will show up here.',
          )
        else
          for (final transaction in recent)
            TransactionTile(
              transaction: transaction,
              onTap: () => openTransaction(context, transaction.id),
            ),
      ],
    );
  }
}
