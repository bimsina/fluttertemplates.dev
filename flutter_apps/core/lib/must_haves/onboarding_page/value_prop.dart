import 'package:flutter/material.dart';

class _Benefit {
  final IconData icon;
  final String title;
  final String body;
  const _Benefit(this.icon, this.title, this.body);
}

class ValueProp extends StatelessWidget {
  const ValueProp({super.key});

  static const _benefits = [
    _Benefit(Icons.savings_outlined, 'Save more',
        'Automatic rules move money to savings for you.'),
    _Benefit(Icons.pie_chart_outline, 'See everything',
        'All your accounts in one clear dashboard.'),
    _Benefit(Icons.shield_moon_outlined, 'Stay protected',
        'Bank-level security and instant fraud alerts.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Icon(Icons.account_balance_wallet_outlined,
                  size: 56, color: scheme.primary),
              const SizedBox(height: 24),
              Text('Money, made simple',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Everything you need to spend, save, and grow.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 36),
              for (final b in _benefits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(b.icon,
                            color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.title,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(b.body,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: FilledButton(
                    onPressed: () {}, child: const Text('Get started')),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                    onPressed: () {}, child: const Text('I already have an account')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
