import 'package:flutter/material.dart';

import '../state/auth_scope.dart';
import 'auth_theme.dart';
import 'key_mark.dart';

/// The layout every form screen shares: a colored header holding the title,
/// and the form on the surface. Stacked on phones, side by side from 760px.
class AuthFrame extends StatelessWidget {
  const AuthFrame({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onBack,
    this.backLabel = 'Back',
    this.backIcon = Icons.arrow_back,
    this.step,
    this.stepCount = 2,
    this.isDanger = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Shows a back button when set.
  final VoidCallback? onBack;
  final String backLabel;
  final IconData backIcon;

  /// The position in a multi-step flow, starting at 1.
  final int? step;
  final int stepCount;

  /// Uses the error colors, for destructive screens.
  final bool isDanger;

  static const wideBreakpoint = 760.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isDanger ? scheme.errorContainer : scheme.brand;
    final foreground = isDanger ? scheme.onErrorContainer : scheme.onBrand;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final header = _Header(
            title: title,
            subtitle: subtitle,
            onBack: onBack,
            backLabel: backLabel,
            backIcon: backIcon,
            step: step,
            stepCount: stepCount,
            color: foreground,
          );
          if (constraints.maxWidth >= wideBreakpoint) {
            return _WideLayout(
              header: header,
              background: background,
              foreground: foreground,
              child: child,
            );
          }
          return _CompactLayout(
            header: header,
            background: background,
            foreground: foreground,
            child: child,
          );
        },
      ),
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.header,
    required this.background,
    required this.foreground,
    required this.child,
  });

  final Widget header;
  final Color background;
  final Color foreground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            child: ColoredBox(
              color: background,
              child: Stack(
                children: [
                  Positioned(
                    right: -56,
                    bottom: -18,
                    child: _BackdropKey(color: foreground, height: 112),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 24),
                    child: header,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.header,
    required this.background,
    required this.foreground,
    required this.child,
  });

  final Widget header;
  final Color background;
  final Color foreground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: ColoredBox(
            color: background,
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    right: -90,
                    bottom: 24,
                    child: _BackdropKey(color: foreground, height: 190),
                  ),
                  Positioned.fill(
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: header,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackdropKey extends StatelessWidget {
  const _BackdropKey({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: -0.32,
        child: KeyMark(color: color.withValues(alpha: 0.13), height: height),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.backLabel,
    required this.backIcon,
    required this.step,
    required this.stepCount,
    required this.color,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final String backLabel;
  final IconData backIcon;
  final int? step;
  final int stepCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appName = AuthScope.of(context).appName;
    final currentStep = step;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onBack != null) ...[
              IconButton(
                onPressed: onBack,
                tooltip: backLabel,
                color: color,
                icon: Icon(backIcon),
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(width: 12),
            ],
            KeyMark(color: color, height: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                appName,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (currentStep != null) ...[
          _StepNotches(step: currentStep, count: stepCount, color: color),
          const SizedBox(height: 10),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            style: text.headlineMedium?.copyWith(color: color),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: text.bodyMedium?.copyWith(
              color: color.withValues(alpha: 0.86),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepNotches extends StatelessWidget {
  const _StepNotches({
    required this.step,
    required this.count,
    required this.color,
  });

  final int step;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= count; i++) ...[
          Container(
            width: 22,
            height: 5,
            decoration: BoxDecoration(
              color: color.withValues(alpha: i <= step ? 1 : 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
        ],
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Step $step of $count',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
