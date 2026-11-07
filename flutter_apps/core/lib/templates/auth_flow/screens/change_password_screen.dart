import 'package:flutter/material.dart';

import '../models/auth_failure.dart';
import '../models/password_strength.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_frame.dart';
import '../widgets/demo_panels.dart';
import '../widgets/form_parts.dart';
import '../widgets/strength_key.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _currentFocus = FocusNode();
  final _nextFocus = FocusNode();
  bool _didSendLink = false;

  PasswordStrength get _strength => PasswordStrength.of(
    _next.text,
    email: AuthScope.read(context).auth.user?.email,
  );

  bool get _isNextValid =>
      _strength.isAcceptable && _next.text != _current.text;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _currentFocus.dispose();
    _nextFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      focusFirstInvalid([
        (_currentFocus, _current.text.isNotEmpty),
        (_nextFocus, _isNextValid),
      ]);
      return;
    }
    final scope = AuthScope.read(context);
    final didChange = await submit(
      () => scope.auth.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      ),
    );
    if (didChange) {
      scope.navigation.back();
    } else if (mounted && failure?.code == AuthFailureCode.wrongPassword) {
      _current.clear();
      _currentFocus.requestFocus();
    }
  }

  Future<void> _sendResetLink() async {
    final auth = AuthScope.read(context).auth;
    final email = auth.user?.email;
    if (email == null) return;
    final didSend = await submit(() => auth.sendPasswordReset(email));
    if (didSend && mounted) setState(() => _didSendLink = true);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final currentFailure = failure;

    return AuthFrame(
      title: 'Change password',
      subtitle: 'Confirm the current one, then choose a new one.',
      onBack: scope.navigation.back,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentFailure != null)
                FormBanner.failure(currentFailure, onRetry: _submit),
              PasswordField(
                controller: _current,
                focusNode: _currentFocus,
                label: 'Current password',
                autofillHint: AutofillHints.password,
                validator: (value) => (value ?? '').isEmpty
                    ? 'Enter your current password.'
                    : null,
                onNext: _nextFocus.requestFocus,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: isBusy || _didSendLink ? null : _sendResetLink,
                  child: Text(
                    _didSendLink ? 'Reset link sent' : 'Forgot it? Email a link',
                  ),
                ),
              ),
              if (_didSendLink) ...[
                const DemoResetPanel(),
                const SizedBox(height: 12),
              ],
              PasswordField(
                controller: _next,
                focusNode: _nextFocus,
                label: 'New password',
                autofillHint: AutofillHints.newPassword,
                validator: (value) {
                  if (!_strength.isAcceptable) {
                    return 'This password doesn\'t meet the rules below.';
                  }
                  if (value == _current.text) {
                    return 'Choose a password you aren\'t using now.';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                onDone: _submit,
              ),
              const SizedBox(height: 12),
              StrengthKey(strength: _strength),
              const SizedBox(height: 20),
              SubmitButton(
                label: 'Change password',
                busyLabel: 'Changing password',
                isBusy: isBusy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
