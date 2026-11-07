import 'package:flutter/material.dart';

import '../data/auth_demo_controls.dart';
import '../models/auth_failure.dart';
import '../state/auth_navigation.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_frame.dart';
import '../widgets/demo_panels.dart';
import '../widgets/form_parts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  int _seenPrefill = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = AuthScope.of(context).auth;
    if (auth.signInPrefill > _seenPrefill) {
      _seenPrefill = auth.signInPrefill;
      _email.text = auth.draftEmail;
      _password.clear();
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _fill(DemoCredentials credentials) {
    _email.text = credentials.email;
    _password.text = credentials.password;
    setState(() => failure = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      focusFirstInvalid([
        (_emailFocus, validateEmail(_email.text) == null),
        (_passwordFocus, _password.text.isNotEmpty),
      ]);
      return;
    }
    final auth = AuthScope.read(context).auth;
    final didSignIn = await submit(
      () => auth.signIn(email: _email.text.trim(), password: _password.text),
    );
    if (!didSignIn &&
        mounted &&
        failure?.code == AuthFailureCode.invalidCredentials) {
      _passwordFocus.requestFocus();
    }
  }

  void _open(AuthRoute route) {
    final scope = AuthScope.read(context);
    scope.auth.draftEmail = _email.text.trim();
    scope.navigation.open(route);
  }

  @override
  Widget build(BuildContext context) {
    final appName = AuthScope.of(context).appName;
    final currentFailure = failure;

    return AuthFrame(
      title: 'Welcome back',
      subtitle: 'Sign in to $appName.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentFailure != null)
                FormBanner.failure(currentFailure, onRetry: _submit),
              EmailField(
                controller: _email,
                focusNode: _emailFocus,
                onNext: _passwordFocus.requestFocus,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _password,
                focusNode: _passwordFocus,
                label: 'Password',
                autofillHint: AutofillHints.password,
                validator: (value) => (value ?? '').isEmpty
                    ? 'Enter your password.'
                    : null,
                onDone: _submit,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => _open(AuthRoute.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 4),
              SubmitButton(
                label: 'Sign in',
                busyLabel: 'Signing in',
                isBusy: isBusy,
                onPressed: _submit,
              ),
              const SizedBox(height: 4),
              PromptLink(
                prompt: 'New here?',
                label: 'Create an account',
                onPressed: () => _open(AuthRoute.signUp),
              ),
              const SizedBox(height: 8),
              DemoAccountPanel(onFill: _fill),
            ],
          ),
        ),
      ),
    );
  }
}
