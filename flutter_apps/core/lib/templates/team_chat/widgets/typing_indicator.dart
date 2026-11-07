import 'dart:math';

import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import 'avatars.dart';
import 'chat_style.dart';

/// A bubble with bouncing dots, shown under the newest message.
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    super.key,
    required this.people,
    required this.showAvatar,
  });

  final List<ChatUser> people;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar) ...[
            UserAvatar(user: people.first, size: 30),
            const SizedBox(width: 8),
          ],
          Semantics(
            label: 'Typing',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.raised,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const BouncingDots(),
            ),
          ),
        ],
      ),
    );
  }
}

class BouncingDots extends StatefulWidget {
  const BouncingDots({super.key});

  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _dot(i, color),
            ],
          ],
        );
      },
    );
  }

  Widget _dot(int index, Color color) {
    final phase = (_controller.value - index * 0.16) % 1;
    final lift = phase < 0.5 ? sin(phase * 2 * pi) : 0.0;
    return Transform.translate(
      offset: Offset(0, -3.5 * lift),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55 + 0.45 * lift),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
