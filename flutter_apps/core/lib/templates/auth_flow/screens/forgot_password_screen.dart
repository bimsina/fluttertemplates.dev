import 'package:flutter/material.dart';

import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_frame.dart';
import '../widgets/demo_panels.dart';
import '../widgets/form_parts.dart';
import '../widgets/resend_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _emailFocus = FocusNode();
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
      text: AuthScope.read(context).auth.draftEmail,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<bool> _send() async {
    final auth = AuthScope.read(context).auth;
    final email = _email.text.trim();
    final didSend = await submit(() => auth.sendPasswordReset(email));
    if (didSend && mounted) setState(() => _sentTo = email);
    return didSend;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _emailFocus.requestFocus();
      return;
    }
    await _send();
  }

  @override
  Widget build(BuildContext context) {
    final navigation = AuthScope.of(context).navigation;
    final sentTo = _sentTo;
    final currentFailure = failure;
    final text = Theme.of(context).textTheme;

    return AuthFrame(
      title: sentTo == null ? 'Reset your password' : 'Check your inbox',
      subtitle: sentTo == null
          ? 'Enter your email and we\'ll send a reset link.'
          : 'If an account exists for $sentTo, a reset link is on its way.',
      onBack: navigation.back,
      backLabel: 'Back to sign in',
      step: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentFailure != null)
            FormBanner.failure(
              currentFailure,
              onRetry: sentTo == null ? _submit : _send,
            ),
          if (sentTo == null)
            AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EmailField(
                      controller: _email,
                      focusNode: _emailFocus,
                      autofocus: true,
                      onDone: _submit,
                    ),
                    const SizedBox(height: 16),
                    SubmitButton(
                      label: 'Send reset link',
                      busyLabel: 'Sending',
                      isBusy: isBusy,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              'The link opens a screen for choosing a new password. It works '
              'once, and a newer link replaces it.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 8),
            ResendButton(
              label: 'Send it again',
              onResend: _send,
              isEnabled: !isBusy,
            ),
            TextButton(
              onPressed: () => setState(() => _sentTo = null),
              child: const Text('Use a different email'),
            ),
            const SizedBox(height: 8),
            const DemoResetPanel(),
          ],
        ],
      ),
    );
  }
}
