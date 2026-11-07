import 'package:flutter/material.dart';

import '../models/account.dart';
import '../state/wallet_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/money_text.dart';
import '../widgets/transaction_browser.dart';
import 'send/recipient_screen.dart';
import 'transaction_detail_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final account = WalletScope.of(context).accountById(accountId);
    if (account == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Account not found',
          message: 'This account is no longer available.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                _AccountSummary(account: account),
                Expanded(
                  child: TransactionBrowser(
                    scope: (t) => t.accountId == accountId,
                    showAccountFilter: false,
                    emptyTitle: 'No activity yet',
                    emptyMessage:
                        'Money moved in or out of ${account.name} will show '
                        'up here.',
                    onOpen: (t) => openTransaction(context, t.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedMoneyText(
                  account.balanceCents,
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  '${account.kind.label}  ${account.mask}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(72, 46)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RecipientScreen(fromAccountId: account.id),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
