import 'package:flutter/material.dart';

import '../state/auth_scope.dart';
import '../widgets/auth_theme.dart';
import '../widgets/key_mark.dart';

/// Shown while the stored session is restored. The app can't know which route
/// to open until this finishes, so a failure here offers a retry instead of
/// guessing.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final auth = scope.auth;
    final failure = auth.restoreFailure;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.brand,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TurningKey(color: scheme.onBrand, isAnimated: failure == null),
                  const SizedBox(height: 20),
                  Text(
                    scope.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: scheme.onBrand,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      failure?.message ?? 'Restoring your session',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onBrand,
                      ),
                    ),
                  ),
                  if (failure != null) ...[
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: auth.restore,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.onBrand,
                        foregroundColor: scheme.brand,
                      ),
                      child: const Text('Try again'),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: auth.continueSignedOut,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onBrand,
                      ),
                      child: const Text('Continue to sign in'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The teeth rise one after another. Holds still when animations are off.
class _TurningKey extends StatefulWidget {
  const _TurningKey({required this.color, required this.isAnimated});

  final Color color;
  final bool isAnimated;

  @override
  State<_TurningKey> createState() => _TurningKeyState();
}

class _TurningKeyState extends State<_TurningKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_TurningKey oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final shouldRun =
        widget.isAnimated && !MediaQuery.disableAnimationsOf(context);
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return KeyMark(
          color: widget.color,
          height: 64,
          teeth: [
            for (var i = 0; i < 4; i++)
              Curves.easeOut.transform(((t * 1.6) - i * 0.2).clamp(0.0, 1.0)) *
                  const [0.7, 1, 0.45, 0.85][i],
          ],
        );
      },
    );
  }
}
