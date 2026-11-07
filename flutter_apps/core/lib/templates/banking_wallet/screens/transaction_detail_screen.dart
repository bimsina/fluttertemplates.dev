import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/formatting.dart';
import '../models/transaction.dart';
import '../state/wallet_controller.dart';
import '../state/wallet_scope.dart';
import '../widgets/category_style.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/money_text.dart';
import '../widgets/receipt_panel.dart';
import 'send/amount_screen.dart';

void openTransaction(BuildContext context, String transactionId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TransactionDetailScreen(transactionId: transactionId),
    ),
  );
}

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: SafeArea(
        top: false,
        child: TransactionDetailView(transactionId: transactionId),
      ),
    );
  }
}

/// The body of the detail screen, also used in the Activity tab's side pane.
class TransactionDetailView extends StatelessWidget {
  const TransactionDetailView({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);
    final transaction = wallet.transactionById(transactionId);
    if (transaction == null) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Transaction not found',
        message: 'It may have been removed by the bank.',
      );
    }
    final payee = wallet.payeeById(transaction.payeeId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReceiptPanel(
                child: _Receipt(transaction: transaction, wallet: wallet),
              ),
              const SizedBox(height: 16),
              if (payee != null && !transaction.isCredit) ...[
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AmountScreen(
                        payee: payee,
                        initialCents: transaction.amountCents.abs(),
                      ),
                    ),
                  ),
                  child: const Text('Send again'),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy reference'),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(
                    ClipboardData(text: transaction.reference),
                  );
                  messenger.showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Reference copied'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt({required this.transaction, required this.wallet});

  final Transaction transaction;
  final WalletController wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final account = wallet.accountById(transaction.accountId);
    final counterAccount = wallet.accountById(transaction.counterAccountId);
    final card = wallet.cardById(transaction.cardId);
    final note = transaction.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: CategoryIcon(category: transaction.category, size: 56)),
        const SizedBox(height: 12),
        Text(
          transaction.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: MoneyText(
            transaction.amountCents,
            signed: true,
            style: theme.textTheme.displaySmall?.copyWith(
              color: transaction.isCredit ? scheme.tertiary : scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: _StatusPill(status: transaction.status)),
        const ReceiptDivider(),
        InfoRow(label: 'Date', value: formatDateTime(transaction.date)),
        InfoRow(label: 'Category', value: transaction.category.label),
        if (account != null)
          InfoRow(label: 'Account', value: '${account.name} ${account.mask}'),
        if (counterAccount != null)
          InfoRow(
            label: transaction.isCredit ? 'From' : 'To',
            value: '${counterAccount.name} ${counterAccount.mask}',
          ),
        if (card != null)
          InfoRow(
            label: 'Card',
            value: card.isFrozen
                ? '•• ${card.lastFour} (frozen)'
                : '•• ${card.lastFour}',
          ),
        if (note != null && note.isNotEmpty)
          InfoRow(label: 'Note', value: note),
        InfoRow(label: 'Reference', value: transaction.reference),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pending = status == TransactionStatus.pending;
    final foreground = pending
        ? scheme.onSecondaryContainer
        : scheme.onTertiaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pending ? scheme.secondaryContainer : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pending ? Icons.schedule : Icons.check,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Fills the side pane until a transaction is picked.
class TransactionDetailPlaceholder extends StatelessWidget {
  const TransactionDetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.touch_app_outlined,
      title: 'Pick a transaction',
      message: 'Its details will open here.',
    );
  }
}
