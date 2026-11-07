import 'package:flutter/material.dart';

/// Above this width the app uses its two-pane and rail layouts.
const wideBreakpoint = 720.0;

/// Centers [child] and stops it growing past [maxWidth] on tablets.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, this.maxWidth = 640, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Horizontal padding that keeps sliver content centered at [maxWidth].
double centeredGutter(double width, double maxWidth, {double min = 16}) {
  final gutter = (width - maxWidth) / 2;
  return gutter > min ? gutter : min;
}

/// A bar pinned under the content, used for the main action of a screen.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: ContentWidth(child: child),
        ),
      ),
    );
  }
}
