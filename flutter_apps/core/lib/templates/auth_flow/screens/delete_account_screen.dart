import 'package:flutter/material.dart';

import '../models/auth_failure.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_frame.dart';
import '../widgets/form_parts.dart';

/// Asking for the password makes this hard to do by accident, and is what
/// providers need before deleting anyway.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen>
    with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _passwordFocus.requestFocus();
      return;
    }
    final auth = AuthScope.read(context).auth;
    final didDelete = await submit(() => auth.deleteAccount(_password.text));
    if (!didDelete &&
        mounted &&
        failure?.code == AuthFailureCode.wrongPassword) {
      _password.clear();
      _passwordFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final currentFailure = failure;

    return AuthFrame(
      title: 'Delete account',
      subtitle: 'This removes ${scope.auth.user?.email ?? 'your account'} '
          'for good. It can\'t be undone.',
      onBack: scope.navigation.back,
      isDanger: true,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentFailure != null)
                FormBanner.failure(currentFailure, onRetry: _submit),
              PasswordField(
                controller: _password,
                focusNode: _passwordFocus,
                label: 'Password',
                autofillHint: AutofillHints.password,
                validator: (value) => (value ?? '').isEmpty
                    ? 'Enter your password to confirm.'
                    : null,
                onDone: _submit,
              ),
              const SizedBox(height: 20),
              SubmitButton(
                label: 'Delete my account',
                busyLabel: 'Deleting account',
                isBusy: isBusy,
                isDanger: true,
                onPressed: _submit,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: isBusy ? null : scope.navigation.back,
                child: const Text('Keep my account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
