import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../state/chat_scope.dart';
import '../state/chat_store.dart';
import 'avatars.dart';
import 'formatting.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isSelected = false,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = store.unreadCount(conversation);
    final hasUnread = unread > 0;
    final last = conversation.lastMessage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: isSelected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                ConversationAvatar(conversation: conversation),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.titleOf(conversation),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatListTime(conversation.updatedAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: hasUnread && !conversation.isMuted
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Preview(
                              store: store,
                              conversation: conversation,
                              last: last,
                              isBold: hasUnread,
                            ),
                          ),
                          if (conversation.isPinned) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.push_pin_rounded,
                              size: 15,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                          if (conversation.isMuted) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.notifications_off_rounded,
                              size: 15,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                          if (hasUnread) ...[
                            const SizedBox(width: 6),
                            UnreadBadge(
                              count: unread,
                              isMuted: conversation.isMuted,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.store,
    required this.conversation,
    required this.last,
    required this.isBold,
  });

  final ChatStore store;
  final Conversation conversation;
  final Message? last;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = theme.textTheme.bodyMedium?.copyWith(
      color: isBold ? scheme.onSurface : scheme.onSurfaceVariant,
      height: 1.3,
    );
    final accent = base?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
    );

    final typing = store.typingLabel(conversation.id);
    final draft = store.draft(conversation.id);
    final failed = store.failedCount(conversation.id);
    final unconfirmed = store.unconfirmedCount(conversation.id);
    final unsent = failed + unconfirmed;

    final InlineSpan span;
    if (typing != null) {
      span = TextSpan(
        text: conversation.isGroup ? typing : 'Typing',
        style: accent,
      );
    } else if (unsent > 0) {
      final outcome = unconfirmed > 0 ? 'may not have sent' : 'not sent';
      span = TextSpan(
        text: unsent == 1 ? 'Message $outcome' : '$unsent messages $outcome',
        style: accent?.copyWith(color: scheme.error),
      );
    } else if (draft.isNotEmpty) {
      span = TextSpan(
        children: [
          TextSpan(text: 'Draft  ', style: accent),
          TextSpan(text: draft.replaceAll('\n', ' ')),
        ],
      );
    } else {
      span = TextSpan(text: _lastMessageText());
    }

    return Text.rich(
      span,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: base,
    );
  }

  String _lastMessageText() {
    final message = last;
    if (message == null) return 'No messages yet';
    if (message.isSystem) return message.text;
    final text = message.isDeleted ? 'Message deleted' : message.text;
    final flat = text.replaceAll('\n', ' ');
    if (message.senderId == store.me.id) return 'You: $flat';
    return conversation.isGroup
        ? '${store.user(message.senderId).firstName}: $flat'
        : flat;
  }
}

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count, this.isMuted = false});

  final int count;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isMuted ? scheme.outlineVariant : scheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        semanticsLabel: '$count unread',
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: isMuted ? scheme.onSurface : scheme.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
