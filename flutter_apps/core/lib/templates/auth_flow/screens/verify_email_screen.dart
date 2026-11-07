import 'package:flutter/material.dart';

import '../models/auth_failure.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_frame.dart';
import '../widgets/code_input.dart';
import '../widgets/demo_panels.dart';
import '../widgets/form_parts.dart';
import '../widgets/resend_button.dart';

/// The only route for a session whose email isn't verified, so an unverified
/// user can't reach the signed-in screens.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SubmitMixin {
  static const _codeLength = 6;

  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  bool _didResend = false;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kept because the user goes null while this route animates out.
    _email = AuthScope.of(context).auth.user?.email ?? _email;
  }

  @override
  void dispose() {
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.text.length != _codeLength) {
      _codeFocus.requestFocus();
      return;
    }
    setState(() => _didResend = false);
    final auth = AuthScope.read(context).auth;
    final didVerify = await submit(() => auth.verifyEmail(_code.text));
    if (didVerify || !mounted) return;
    if (failure?.code == AuthFailureCode.invalidCode) _code.clear();
    _codeFocus.requestFocus();
  }

  Future<bool> _resend() async {
    final auth = AuthScope.read(context).auth;
    final didSend = await submit(auth.resendVerification);
    if (didSend && mounted) {
      _code.clear();
      setState(() => _didResend = true);
      _codeFocus.requestFocus();
    }
    return didSend;
  }

  void _useCode(String code) {
    _code.text = code;
    _verify();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final auth = scope.auth;
    final currentFailure = failure;
    final isExpired = currentFailure?.code == AuthFailureCode.expiredCode;
    final text = Theme.of(context).textTheme;

    return AuthFrame(
      title: 'Check your email',
      subtitle: 'Enter the 6 digit code sent to $_email.',
      step: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentFailure != null)
            FormBanner.failure(
              currentFailure,
              onRetry: _code.text.length == _codeLength ? _verify : null,
            ),
          CodeInput(
            controller: _code,
            focusNode: _codeFocus,
            length: _codeLength,
            isEnabled: !isBusy,
            hasError: currentFailure != null,
            autofocus: true,
            onCompleted: _verify,
          ),
          if (_didResend)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text('A new code is on its way.', style: text.bodyMedium),
              ),
            ),
          const SizedBox(height: 16),
          SubmitButton(
            label: 'Verify email',
            busyLabel: 'Checking code',
            isBusy: isBusy,
            onPressed: _verify,
          ),
          const SizedBox(height: 4),
          ResendButton(
            label: 'Send a new code',
            onResend: _resend,
            skipCooldown: isExpired,
            isEnabled: !isBusy,
          ),
          TextButton(
            onPressed: isBusy ? null : () => submit(auth.signOut),
            child: const Text('Use a different email'),
          ),
          const SizedBox(height: 8),
          DemoCodePanel(onUseCode: _useCode),
        ],
      ),
    );
  }
}
