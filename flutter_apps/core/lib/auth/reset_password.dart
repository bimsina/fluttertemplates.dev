import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String _password = '';
  String _confirm = '';
  bool _obscure = true;

  bool get _hasLength => _password.length >= 8;
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password);
  bool get _matches => _password.isNotEmpty && _password == _confirm;
  bool get _valid => _hasLength && _hasNumber && _matches;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Set a new password',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Your new password must be different from previously used passwords.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          TextField(
            obscureText: _obscure,
            onChanged: (v) => setState(() => _password = v),
            decoration: InputDecoration(
              labelText: 'New password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: _obscure,
            onChanged: (v) => setState(() => _confirm = v),
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          _Rule(label: 'At least 8 characters', met: _hasLength),
          _Rule(label: 'Contains a number', met: _hasNumber),
          _Rule(label: 'Passwords match', met: _matches),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _valid ? () {} : null,
              child: const Text('Reset password'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String label;
  final bool met;
  const _Rule({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.circle_outlined,
              size: 18, color: met ? Colors.green : scheme.outline),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: met ? scheme.onSurface : scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
