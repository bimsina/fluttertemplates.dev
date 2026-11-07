import 'package:flutter/material.dart';

import '../models/auth_failure.dart';
import '../models/password_strength.dart';
import '../state/auth_scope.dart';
import '../state/submit_mixin.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_frame.dart';
import '../widgets/form_parts.dart';
import '../widgets/strength_key.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final TextEditingController _email;
  final _password = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: AuthScope.read(context).auth.draftEmail);
    _email.addListener(_refreshStrength);
  }

  void _refreshStrength() => setState(() {});

  PasswordStrength get _strength =>
      PasswordStrength.of(_password.text, email: _email.text.trim());

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      focusFirstInvalid([
        (_nameFocus, _name.text.trim().isNotEmpty),
        (_emailFocus, validateEmail(_email.text) == null),
        (_passwordFocus, _strength.isAcceptable),
      ]);
      return;
    }
    final auth = AuthScope.read(context).auth;
    await submit(
      () => auth.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      ),
    );
  }

  void _signInInstead() {
    final scope = AuthScope.read(context);
    scope.auth.prefillSignIn(_email.text.trim());
    scope.navigation.back();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final currentFailure = failure;
    final isTaken = currentFailure?.code == AuthFailureCode.emailTaken;

    return AuthFrame(
      title: 'Create your account',
      subtitle: 'We\'ll send a code to confirm your email.',
      onBack: scope.navigation.back,
      backLabel: 'Back to sign in',
      step: 1,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentFailure != null)
                isTaken
                    ? FormBanner(
                        message: currentFailure.message,
                        actionLabel: 'Sign in instead',
                        onAction: _signInInstead,
                      )
                    : FormBanner.failure(currentFailure, onRetry: _submit),
              TextFormField(
                controller: _name,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Enter your name.'
                    : null,
                onEditingComplete: _emailFocus.requestFocus,
              ),
              const SizedBox(height: 12),
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
                autofillHint: AutofillHints.newPassword,
                validator: (_) => _strength.isAcceptable
                    ? null
                    : 'This password doesn\'t meet the rules below.',
                onChanged: (_) => _refreshStrength(),
                onDone: _submit,
              ),
              const SizedBox(height: 12),
              StrengthKey(strength: _strength),
              const SizedBox(height: 20),
              SubmitButton(
                label: 'Create account',
                busyLabel: 'Creating account',
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
