import 'package:flutter/material.dart';

import 'chat_style.dart';

/// Top bar for every screen below the conversation list.
class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.hairline)),
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                if (leading != null) leading! else const SizedBox(width: 10),
                Expanded(child: child),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
