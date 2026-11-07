import 'package:flutter/material.dart';

import '../../models/payee.dart';
import '../../state/wallet_scope.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/payee_avatar.dart';
import 'add_recipient_screen.dart';
import 'amount_screen.dart';

/// First step of a transfer: pick who gets the money.
class RecipientScreen extends StatefulWidget {
  const RecipientScreen({super.key, this.fromAccountId});

  /// Preselects the source account when the flow starts from an account.
  final String? fromAccountId;

  @override
  State<RecipientScreen> createState() => _RecipientScreenState();
}

class _RecipientScreenState extends State<RecipientScreen> {
  String _query = '';

  void _select(Payee payee) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AmountScreen(payee: payee, fromAccountId: widget.fromAccountId),
      ),
    );
  }

  Future<void> _addRecipient() async {
    final payee = await Navigator.of(context).push<Payee>(
      MaterialPageRoute(builder: (_) => const AddRecipientScreen()),
    );
    if (payee != null && mounted) _select(payee);
  }

  bool _matches(Payee payee) {
    final query = _query.trim().toLowerCase();
    return query.isEmpty ||
        payee.name.toLowerCase().contains(query) ||
        payee.bankName.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = WalletScope.of(context);
    final own = wallet.ownAccountPayees
        .where((payee) => payee.ownAccountId != widget.fromAccountId)
        .where(_matches)
        .toList();
    final people = wallet.payees.where(_matches).toList();
    final nothingFound = own.isEmpty && people.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search name or bank',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: nothingFound
                      ? EmptyState(
                          icon: Icons.person_search_outlined,
                          title: wallet.payees.isEmpty
                              ? 'No recipients yet'
                              : 'No one by that name',
                          message: 'Add them once and they will be saved here.',
                          actionLabel: 'Add a recipient',
                          onAction: _addRecipient,
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                          children: [
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                child: const Icon(Icons.person_add_alt),
                              ),
                              title: const Text('New recipient'),
                              onTap: _addRecipient,
                            ),
                            if (own.isNotEmpty) ...[
                              const _SectionLabel('Your accounts'),
                              for (final payee in own)
                                _PayeeTile(
                                  payee: payee,
                                  onTap: () => _select(payee),
                                ),
                            ],
                            if (people.isNotEmpty) ...[
                              const _SectionLabel('People'),
                              for (final payee in people)
                                _PayeeTile(
                                  payee: payee,
                                  onTap: () => _select(payee),
                                ),
                            ],
                          ],
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PayeeTile extends StatelessWidget {
  const _PayeeTile({required this.payee, required this.onTap});

  final Payee payee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: PayeeAvatar(payee: payee),
      title: Text(payee.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${payee.bankName}  ${payee.mask}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
