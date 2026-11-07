import 'package:flutter/material.dart';

import '../../models/formatting.dart';
import '../../models/payee.dart';
import '../../models/transfer.dart';
import '../../state/wallet_scope.dart';
import '../../widgets/info_row.dart';
import '../../widgets/payee_avatar.dart';
import '../../widgets/receipt_panel.dart';
import '../../widgets/slide_to_confirm.dart';
import '../../widgets/wallet_theme.dart';
import 'success_screen.dart';

/// Last step of a transfer. Nothing moves until the customer slides to send.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.payee,
    required this.fromAccountId,
    required this.amountCents,
  });

  final Payee payee;
  final String fromAccountId;
  final int amountCents;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _note = TextEditingController();
  static const _unknownMessage =
      'We could not confirm this transfer, and it may have gone through. '
      'Check Activity before you do anything else. Retrying here is safe: '
      'it can only pay once.';

  bool _sending = false;
  String? _error;

  /// The attempt in progress. It is kept until the outcome is known, so every
  /// retry resends the same key and details.
  TransferRequest? _attempt;
  bool _outcomeUnknown = false;

  @override
  void initState() {
    super.initState();
    final unresolved = WalletScope.read(context).unresolvedTransfer(
      fromAccountId: widget.fromAccountId,
      payeeId: widget.payee.id,
      amountCents: widget.amountCents,
    );
    if (unresolved != null) {
      _attempt = unresolved;
      _outcomeUnknown = true;
      _error = _unknownMessage;
      _note.text = unresolved.note ?? '';
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final note = _note.text.trim();
    final request = _attempt ??= TransferRequest(
      idempotencyKey: generateIdempotencyKey(),
      fromAccountId: widget.fromAccountId,
      payee: widget.payee,
      amountCents: widget.amountCents,
      note: note.isEmpty ? null : note,
    );
    final outcome = await WalletScope.read(context).sendMoney(request);
    if (!mounted) return;
    switch (outcome) {
      case TransferCommitted(:final transaction):
        // Replaces the whole send flow, so back leads home and can't resend.
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => SuccessScreen(
              transactionId: transaction.id,
              payeeName: widget.payee.name,
              accountId: widget.fromAccountId,
              amountCents: widget.amountCents,
            ),
          ),
          (route) => route.isFirst,
        );
      case TransferRejected(:final message):
        // Nothing moved, so the next slide is a new attempt with a new key.
        setState(() {
          _sending = false;
          _attempt = null;
          _outcomeUnknown = false;
          _error = message;
        });
      case TransferUnknown():
        setState(() {
          _sending = false;
          _outcomeUnknown = true;
          _error = _unknownMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wallet = WalletScope.of(context);
    final source = wallet.accountById(widget.fromAccountId);
    final remaining = (source?.balanceCents ?? 0) - widget.amountCents;

    return PopScope(
      canPop: !_sending,
      child: Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      children: [
                        ReceiptPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: PayeeAvatar(
                                  payee: widget.payee,
                                  size: 52,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.payee.name,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                '${widget.payee.bankName}  ${widget.payee.mask}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatCents(widget.amountCents),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontFeatures: tabularFigures,
                                  ),
                                ),
                              ),
                              const ReceiptDivider(),
                              InfoRow(
                                label: 'From',
                                value: source == null
                                    ? ''
                                    : '${source.name} ${source.mask}',
                              ),
                              const InfoRow(label: 'Fee', value: r'$0.00'),
                              const InfoRow(
                                label: 'Arrives',
                                value: 'Instantly',
                              ),
                              // Unknowable while the first try is in doubt.
                              if (!_outcomeUnknown)
                                InfoRow(
                                  label: 'Balance after',
                                  value: formatCents(remaining),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _note,
                          maxLength: 60,
                          // A retry has to match the first try exactly.
                          enabled: !_sending && !_outcomeUnknown,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.error,
                              ),
                            ),
                          ),
                        SlideToConfirm(
                          label: _outcomeUnknown
                              ? 'Slide to retry'
                              : 'Slide to send',
                          busy: _sending,
                          onConfirmed: _send,
                        ),
                      ],
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
