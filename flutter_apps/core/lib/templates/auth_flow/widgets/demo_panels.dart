import 'package:flutter/material.dart';

import '../data/auth_demo_controls.dart';
import '../state/auth_scope.dart';

/// Panels that show what only exists in the demo: a login to try, the emails a
/// real backend would send, and ways to force failures.
///
/// The dashed border marks them as not part of the product. Each one renders
/// nothing unless the repository implements [AuthDemoControls], so with a real
/// backend they vanish without any code changes.
class _DemoFrame extends StatelessWidget {
  const _DemoFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CustomPaint(
      painter: _DashedBorder(color: scheme.outline),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      'DEMO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onTertiaryContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                Text(title, style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    for (final metric in outline.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 10) {
        canvas.drawPath(metric.extractPath(start, start + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}

class _FailNextSwitch extends StatelessWidget {
  const _FailNextSwitch({required this.demo});

  final AuthDemoControls demo;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: demo.failNextRequest,
      onChanged: (value) => demo.failNextRequest = value,
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text('Fail the next request'),
    );
  }
}

/// The login to try, on the sign-in screen.
class DemoAccountPanel extends StatelessWidget {
  const DemoAccountPanel({super.key, required this.onFill});

  final void Function(DemoCredentials credentials) onFill;

  @override
  Widget build(BuildContext context) {
    final demo = AuthScope.of(context).demo;
    if (demo == null) return const SizedBox.shrink();
    final account = demo.demoAccount;
    final text = Theme.of(context).textTheme;

    return _DemoFrame(
      title: 'Try it with this account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (account == null) ...[
            Text('The demo account was deleted.', style: text.bodyMedium),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: demo.restoreDemoAccount,
              child: const Text('Restore demo account'),
            ),
          ] else ...[
            Text(account.email, style: text.bodyMedium),
            Text(account.password, style: text.bodyMedium),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => onFill(account),
              child: const Text('Fill in demo account'),
            ),
          ],
          _FailNextSwitch(demo: demo),
        ],
      ),
    );
  }
}

/// The email a real backend would send during verification.
class DemoCodePanel extends StatelessWidget {
  const DemoCodePanel({super.key, required this.onUseCode});

  final ValueChanged<String> onUseCode;

  @override
  Widget build(BuildContext context) {
    final demo = AuthScope.of(context).demo;
    final email = demo?.verificationEmail;
    final code = email?.code;
    if (demo == null || email == null || code == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);

    return _DemoFrame(
      title: 'A real app would email this',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            code,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              decoration: email.isExpired ? TextDecoration.lineThrough : null,
            ),
          ),
          if (email.isExpired)
            Text('Expired', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton(
                onPressed: () => onUseCode(code),
                child: const Text('Use this code'),
              ),
              if (!email.isExpired)
                TextButton(
                  onPressed: demo.expireVerificationCode,
                  child: const Text('Expire it'),
                ),
            ],
          ),
          _FailNextSwitch(demo: demo),
        ],
      ),
    );
  }
}

/// The reset email, with a button that acts as tapping its link.
class DemoResetPanel extends StatelessWidget {
  const DemoResetPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final demo = AuthScope.of(context).demo;
    final email = demo?.resetEmail;
    if (demo == null || email == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    if (!email.isDelivered) {
      return _DemoFrame(
        title: 'Nothing was sent',
        child: Text(
          'No account uses ${email.to}. The screen above doesn\'t reveal that, '
          'so nobody can use this form to find out who has an account.',
          style: text.bodyMedium,
        ),
      );
    }
    return _DemoFrame(
      title: 'A real app would email this',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            email.isExpired
                ? 'The reset link for ${email.to} has expired.'
                : 'Reset link for ${email.to}',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton(
                onPressed: demo.openRecoveryLink,
                child: const Text('Open reset link'),
              ),
              if (!email.isExpired)
                TextButton(
                  onPressed: demo.expireResetLink,
                  child: const Text('Expire it'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Session events to trigger by hand, on the home screen.
class DemoSessionPanel extends StatelessWidget {
  const DemoSessionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final demo = scope.demo;
    if (demo == null) return const SizedBox.shrink();

    return _DemoFrame(
      title: 'Trigger what a backend would',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: demo.expireSession,
                child: const Text('Expire session'),
              ),
              OutlinedButton(
                onPressed: demo.openRecoveryLink,
                child: const Text('Open a reset link'),
              ),
              OutlinedButton(
                onPressed: scope.auth.restore,
                child: const Text('Relaunch app'),
              ),
            ],
          ),
          _FailNextSwitch(demo: demo),
        ],
      ),
    );
  }
}
