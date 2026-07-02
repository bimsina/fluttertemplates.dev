import 'package:flutter/material.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_unread_outlined,
                    size: 60, color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 28),
            Text('Verify your email',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                children: const [
                  TextSpan(text: 'We sent a verification link to\n'),
                  TextSpan(
                      text: 'alex@example.com',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '. Click the link to activate your account.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open email app'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't get it?",
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                TextButton(onPressed: () {}, child: const Text('Resend email')),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
