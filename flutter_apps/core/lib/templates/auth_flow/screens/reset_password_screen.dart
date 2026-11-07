import 'package:flutter/material.dart';

import '../models/auth_failure.dart';
import '../models/password_strength.dart';
import '../state/auth_controller.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_frame.dart';
import '../widgets/demo_panels.dart';
import '../widgets/form_parts.dart';
import '../widgets/strength_key.dart';

/// Opened by a reset link. It always sits on top of the stack, so whatever was
/// open stays underneath and comes back if this is cancelled.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _didSendNewLink = false;

  PasswordStrength get _strength =>
      PasswordStrength.of(_password.text, email: widget.email);

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
    final scope = AuthScope.read(context);
    final didReset = await submit(
      () => scope.auth.completeRecovery(_password.text),
    );
    // Signed out, the only sensible place to land is the sign-in screen, so
    // close the forgot password route that was underneath.
    if (didReset && scope.auth.status == AuthStatus.signedOut) {
      scope.navigation.closeAll();
    }
  }

  Future<void> _sendNewLink() async {
    final auth = AuthScope.read(context).auth;
    final didSend = await submit(() => auth.sendPasswordReset(widget.email));
    if (didSend && mounted) setState(() => _didSendNewLink = true);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final currentFailure = failure;
    final isExpired = currentFailure?.code == AuthFailureCode.expiredLink;
    final showExpired = isExpired || _didSendNewLink;
    final user = scope.auth.user;
    final text = Theme.of(context).textTheme;

    return AuthFrame(
      title: 'Choose a new password',
      subtitle: 'For ${widget.email}.',
      onBack: scope.navigation.back,
      backLabel: 'Cancel password reset',
      backIcon: Icons.close,
      step: 2,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isExpired)
                FormBanner(
                  message: currentFailure!.message,
                  actionLabel: 'Send a new link',
                  onAction: _sendNewLink,
                )
              else if (currentFailure != null)
                FormBanner.failure(
                  currentFailure,
                  onRetry: _didSendNewLink ? _sendNewLink : _submit,
                ),
              if (_didSendNewLink) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'A new link is on its way to ${widget.email}. Open it to '
                    'continue.',
                    style: text.bodyMedium,
                  ),
                ),
                const SizedBox(height: 12),
                const DemoResetPanel(),
              ],
              if (!showExpired) ...[
                if (user != null && user.email != widget.email)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'You\'re signed in as ${user.email}. This changes the '
                      'password for ${widget.email} and leaves you signed in.',
                      style: text.bodyMedium,
                    ),
                  ),
                PasswordField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  label: 'New password',
                  autofillHint: AutofillHints.newPassword,
                  autofocus: true,
                  validator: (_) => _strength.isAcceptable
                      ? null
                      : 'This password doesn\'t meet the rules below.',
                  onChanged: (_) => setState(() {}),
                  onDone: _submit,
                ),
                const SizedBox(height: 12),
                StrengthKey(strength: _strength),
                const SizedBox(height: 20),
                SubmitButton(
                  label: 'Update password',
                  busyLabel: 'Updating password',
                  isBusy: isBusy,
                  onPressed: _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
