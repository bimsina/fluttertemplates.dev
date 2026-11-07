import 'package:flutter/material.dart';

class SignupTerms extends StatefulWidget {
  const SignupTerms({super.key});

  @override
  State<SignupTerms> createState() => _SignupTermsState();
}

class _SignupTermsState extends State<SignupTerms> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _minStrength = 3;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _password = '';
  bool _agreed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();
  bool get _emailValid => _emailPattern.hasMatch(_email);

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _emailValid &&
      _strength >= _minStrength &&
      _agreed;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created for $_email')),
    );
  }

  int get _strength {
    var score = 0;
    if (_password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) score++;
    if (RegExp(r'[0-9]').hasMatch(_password)) score++;
    if (RegExp(r'[!@#$%^&*]').hasMatch(_password)) score++;
    return score;
  }

  static const _labels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = [
      scheme.error,
      scheme.error,
      Colors.orange,
      Colors.amber,
      Colors.green,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Get started free',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.mail_outline),
              border: const OutlineInputBorder(),
              errorText: _email.isEmpty || _emailValid
                  ? null
                  : 'Enter a valid email address',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            onChanged: (v) => setState(() => _password = v),
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (i) {
              final active = i < _strength;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: active ? colors[_strength] : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
              'Strength: ${_labels[_strength]}'
              '${_strength < _minStrength ? ' (needs ${_labels[_minStrength]})' : ''}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('I agree to the Terms of Service and Privacy Policy'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _canSubmit ? _submit : null,
              child: const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}
