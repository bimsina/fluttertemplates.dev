import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import 'avatars.dart';

/// A teammate in a list. Pass [isChecked] to show a selection mark.
class PersonTile extends StatelessWidget {
  const PersonTile({
    super.key,
    required this.user,
    required this.onTap,
    this.subtitle,
    this.isChecked,
    this.trailing,
  });

  final ChatUser user;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool? isChecked;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isChecked = this.isChecked;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        child: Row(
          children: [
            UserAvatar(user: user, size: 42, showPresence: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle ?? user.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
            if (isChecked != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: isChecked ? scheme.primary : Colors.transparent,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isChecked ? scheme.primary : scheme.outline,
                      width: 1.5,
                    ),
                  ),
                ),
                child: isChecked
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: scheme.onPrimary,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
