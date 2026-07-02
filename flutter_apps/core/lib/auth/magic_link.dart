import 'package:flutter/material.dart';

class MagicLink extends StatefulWidget {
  const MagicLink({super.key});

  @override
  State<MagicLink> createState() => _MagicLinkState();
}

class _MagicLinkState extends State<MagicLink> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _sent
              ? [
                  const Spacer(),
                  Icon(Icons.mark_email_read_outlined,
                      size: 72, color: scheme.primary),
                  const SizedBox(height: 20),
                  Text('Check your inbox',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    'We sent a magic sign-in link to alex@example.com. Tap the link to log in — no password needed.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _sent = false),
                    child: const Text('Use a different email'),
                  ),
                ]
              : [
                  const Spacer(),
                  Icon(Icons.auto_awesome, size: 64, color: scheme.primary),
                  const SizedBox(height: 20),
                  Text('Passwordless login',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Enter your email and we\'ll send you a secure sign-in link.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 28),
                  const TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _sent = true),
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Send magic link'),
                    ),
                  ),
                  const Spacer(),
                ],
        ),
      ),
    );
  }
}
