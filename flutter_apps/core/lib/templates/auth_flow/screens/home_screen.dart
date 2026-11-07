import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../state/auth_navigation.dart';
import '../state/auth_scope.dart';
import '../widgets/auth_theme.dart';
import '../widgets/demo_panels.dart';
import '../widgets/key_mark.dart';

/// Where a signed-in user lands, and where your app starts. Replace the body
/// with your own screen. Keep the route in `AuthNavigation` and everything
/// around it keeps working.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AuthScope.of(context);
    final user = scope.auth.user;
    // Null for a moment while the route animates out after sign-out.
    if (user == null) return const Scaffold();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                const startHere = _StartHereCard();
                const demo = DemoSessionPanel();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              'Hello, ${user.firstName}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () =>
                              scope.navigation.open(AuthRoute.settings),
                          tooltip: 'Account settings',
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _SessionPass(user: user)),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                startHere,
                                SizedBox(height: 16),
                                demo,
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _SessionPass(user: user),
                      const SizedBox(height: 16),
                      startHere,
                      const SizedBox(height: 16),
                      demo,
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The session as a pass: the person on the top half, the state of their
/// session on the stub.
class _SessionPass extends StatelessWidget {
  const _SessionPass({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final time = TimeOfDay.fromDateTime(user.lastSignInAt).format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipPath(
          clipper: const _PassClipper(notchAtBottom: true),
          child: ColoredBox(
            color: scheme.brand,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: 8,
                  child: IgnorePointer(
                    child: KeyMark(
                      color: scheme.onBrand.withValues(alpha: 0.13),
                      height: 88,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: scheme.onBrand,
                        foregroundColor: scheme.brand,
                        child: ExcludeSemantics(
                          child: FittedBox(child: Text(user.initials)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onBrand,
                              ),
                            ),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onBrand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipPath(
          clipper: const _PassClipper(notchAtBottom: false),
          child: ColoredBox(
            color: scheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Wrap(
                spacing: 28,
                runSpacing: 12,
                children: [
                  _PassField(label: 'Session', value: 'Active since $time'),
                  const _PassField(label: 'Email', value: 'Verified'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PassField extends StatelessWidget {
  const _PassField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// A rounded rectangle with a half circle bitten out of each side where the
/// two halves of the pass meet.
class _PassClipper extends CustomClipper<Path> {
  const _PassClipper({required this.notchAtBottom});

  final bool notchAtBottom;

  @override
  Path getClip(Size size) {
    const radius = Radius.circular(24);
    const notch = 10.0;
    final rect = Offset.zero & size;
    final y = notchAtBottom ? size.height : 0.0;
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        notchAtBottom
            ? RRect.fromRectAndCorners(rect, topLeft: radius, topRight: radius)
            : RRect.fromRectAndCorners(
                rect,
                bottomLeft: radius,
                bottomRight: radius,
              ),
      )
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: notch));
  }

  @override
  bool shouldReclip(_PassClipper old) => old.notchAtBottom != notchAtBottom;
}

class _StartHereCard extends StatelessWidget {
  const _StartHereCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your app starts here',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Replace this screen with your own. Only a verified, signed-in '
            'user can reach it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
