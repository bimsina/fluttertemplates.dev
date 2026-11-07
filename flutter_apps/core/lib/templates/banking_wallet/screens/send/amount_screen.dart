import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../models/amount_input.dart';
import '../../models/formatting.dart';
import '../../models/payee.dart';
import '../../models/transfer.dart';
import '../../state/wallet_scope.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/payee_avatar.dart';
import '../../widgets/wallet_theme.dart';
import 'review_screen.dart';

/// Second step of a transfer: how much, and from which account.
class AmountScreen extends StatefulWidget {
  const AmountScreen({
    super.key,
    required this.payee,
    this.fromAccountId,
    this.initialCents = 0,
  });

  final Payee payee;
  final String? fromAccountId;
  final int initialCents;

  @override
  State<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  late AmountInput _amount = AmountInput.fromCents(widget.initialCents);
  late String? _fromAccountId = widget.fromAccountId;

  /// The chosen source, or the first account that isn't the destination.
  Account? _source(List<Account> accounts) {
    final eligible = accounts.where((a) => a.id != widget.payee.ownAccountId);
    for (final account in eligible) {
      if (account.id == _fromAccountId) return account;
    }
    return eligible.isEmpty ? null : eligible.first;
  }

  String? _validationError(Account source) {
    final cents = _amount.cents;
    if (cents > transferLimitCents) {
      return 'The limit is ${formatCents(transferLimitCents, decimals: false)} '
          'per transfer';
    }
    if (cents > source.balanceCents) {
      return 'More than the ${formatCents(source.balanceCents)} '
          'in ${source.name}';
    }
    return null;
  }

  Future<void> _pickSource(Account current) async {
    final accounts = WalletScope.read(
      context,
    ).accounts.where((a) => a.id != widget.payee.ownAccountId).toList();
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          children: [
            for (final account in accounts)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selected: account.id == current.id,
                title: Text(account.name),
                subtitle: Text(formatCents(account.balanceCents)),
                trailing: account.id == current.id
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(account.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _fromAccountId = picked);
  }

  void _continue(Account source) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewScreen(
          payee: widget.payee,
          fromAccountId: source.id,
          amountCents: _amount.cents,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = WalletScope.of(context).accounts;
    final source = _source(accounts);
    if (source == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.account_balance_outlined,
          title: 'No account to send from',
          message: 'You need another account to make this transfer.',
        ),
      );
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final error = _validationError(source);
    final canContinue = _amount.cents > 0 && error == null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            PayeeAvatar(payee: widget.payee, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.payee.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 820),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: max(constraints.maxHeight, 500),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _amount.display,
                                    style: theme.textTheme.displayMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1.5,
                                          fontFeatures: tabularFigures,
                                          color: error == null
                                              ? (_amount.isEmpty
                                                    ? scheme.onSurfaceVariant
                                                    : scheme.onSurface)
                                              : scheme.error,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  error ?? ' ',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _SourceButton(
                            account: source,
                            onTap: () => _pickSource(source),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            flex: 7,
                            child: NumericKeypad(
                              allowDecimal: true,
                              onKey: (key) =>
                                  setState(() => _amount = _amount.append(key)),
                              onBackspace: () =>
                                  setState(() => _amount = _amount.backspace()),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: canContinue
                                ? () => _continue(source)
                                : null,
                            child: const Text('Review'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.account, required this.onTap});

  final Account account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'From ${account.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatCents(account.balanceCents),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontFeatures: tabularFigures,
                ),
              ),
              Icon(
                Icons.unfold_more,
                size: 18,
                color: scheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
