import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/payee.dart';
import '../../state/wallet_scope.dart';

/// Saves a new payee, and pops with it so the transfer can carry on.
class AddRecipientScreen extends StatefulWidget {
  const AddRecipientScreen({super.key});

  @override
  State<AddRecipientScreen> createState() => _AddRecipientScreenState();
}

class _AddRecipientScreenState extends State<AddRecipientScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _bank = TextEditingController();
  final TextEditingController _account = TextEditingController();
  bool _saving = false;
  String? _error;

  /// The last save got no answer. The details stay locked, because a retry
  /// only stays safe while it matches the first try.
  bool _outcomeUnknown = false;

  @override
  void dispose() {
    _name.dispose();
    _bank.dispose();
    _account.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter their full name';
    if (name.length < 2) return 'That name looks too short';
    return null;
  }

  String? _validateBank(String? value) {
    return (value?.trim() ?? '').isEmpty ? 'Enter their bank' : null;
  }

  String? _validateAccount(String? value) {
    final digits = value?.trim() ?? '';
    if (digits.isEmpty) return 'Enter their account number';
    if (digits.length < 8) return 'Account numbers have at least 8 digits';
    final duplicate = WalletScope.read(
      context,
    ).payees.any((payee) => payee.accountNumber == digits);
    return duplicate ? 'You already saved this account' : null;
  }

  Future<void> _save() async {
    if (_saving) return;
    // The payee may have reached the list by now, which the duplicate check
    // would read as a mistake.
    if (!_outcomeUnknown && !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final outcome = await WalletScope.read(context).addPayee(
      name: _name.text.trim(),
      bankName: _bank.text.trim(),
      accountNumber: _account.text.trim(),
    );
    if (!mounted) return;
    switch (outcome) {
      case PayeeSaved(:final payee):
        navigator.pop(payee);
      case PayeeRejected(:final message):
        setState(() {
          _saving = false;
          _outcomeUnknown = false;
          _error = message;
        });
      case PayeeUnknown():
        setState(() {
          _saving = false;
          _outcomeUnknown = true;
          _error =
              'We could not confirm this recipient, and they may be saved '
              'already. Retrying is safe: it can only save them once.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New recipient')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _name,
                    autofocus: true,
                    readOnly: _outcomeUnknown,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateName,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bank,
                    readOnly: _outcomeUnknown,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateBank,
                    decoration: const InputDecoration(labelText: 'Bank'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _account,
                    readOnly: _outcomeUnknown,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateAccount,
                    onFieldSubmitted: (_) => _save(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Account number',
                      helperText: '8 to 12 digits',
                    ),
                  ),
                  if (_error case final error?) ...[
                    const SizedBox(height: 14),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(
                      _saving
                          ? 'Saving'
                          : _outcomeUnknown
                          ? 'Retry'
                          : 'Save and continue',
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
