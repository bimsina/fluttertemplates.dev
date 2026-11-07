import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  /// Called by 'Get started'.
  final VoidCallback? onGetStarted;

  /// Called by 'I already have an account'.
  final VoidCallback? onSignIn;

  /// Each callback is optional. Without one, the demo shows a SnackBar.
  const Welcome({super.key, this.onGetStarted, this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Shift away from onPrimary, so contrast with the text can only improve.
    final shade =
        scheme.onPrimary.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final gradientEnd = Color.lerp(scheme.primary, shade, 0.3)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(Icons.bolt_rounded, size: 52, color: scheme.onPrimary),
                ),
                const SizedBox(height: 28),
                Text(
                  'Welcome to Nimbus',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Plan your day, track your habits, and stay in flow — all in one calm workspace.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onGetStarted ??
                      () => _showDemo(context, 'Sign up goes here (demo)'),
                  style: FilledButton.styleFrom(
                      backgroundColor: scheme.onPrimary,
                      foregroundColor: scheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Get started'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSignIn ??
                    () => _showDemo(context, 'Sign in goes here (demo)'),
                child: Text(
                  'I already have an account',
                    style: TextStyle(color: scheme.onPrimary),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
