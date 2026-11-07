import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/chat_user.dart';
import '../models/message.dart';
import 'avatars.dart';
import 'chat_style.dart';
import 'formatting.dart';

class MessageRow extends StatefulWidget {
  const MessageRow({
    super.key,
    required this.message,
    required this.sender,
    required this.isMine,
    required this.isGroup,
    required this.startsGroup,
    required this.endsGroup,
    required this.myId,
    required this.onActions,
    required this.onReply,
    required this.onToggleReaction,
    this.quoted,
    this.quotedSenderLabel,
    this.onQuoteTap,
    this.isHighlighted = false,
    this.canReply = true,
    this.onRetry,
    this.onEdit,
  });

  final Message message;
  final ChatUser sender;
  final bool isMine;
  final bool isGroup;
  final bool startsGroup;
  final bool endsGroup;
  final String myId;
  final VoidCallback onActions;
  final VoidCallback onReply;
  final ValueChanged<ReactionKind> onToggleReaction;
  final Message? quoted;
  final String? quotedSenderLabel;
  final VoidCallback? onQuoteTap;
  final bool isHighlighted;

  /// False for a message that hasn't reached the repository yet.
  final bool canReply;

  /// Shown under a failed message.
  final VoidCallback? onRetry;
  final VoidCallback? onEdit;

  @override
  State<MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  static const _avatarSize = 30.0;
  static const _avatarGap = 8.0;

  bool _isHovered = false;

  bool get _showAvatarColumn => widget.isGroup && !widget.isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = widget.message;
    final isMine = widget.isMine;
    final canAct = !message.isDeleted;
    final indent = _showAvatarColumn ? _avatarSize + _avatarGap : 0.0;

    final actions = Visibility(
      visible: canAct && _isHovered,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: IconButton(
        tooltip: 'Message actions',
        onPressed: widget.onActions,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        color: scheme.onSurfaceVariant,
        icon: const Icon(Icons.add_reaction_outlined),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: widget.isHighlighted
            ? scheme.primary.withValues(alpha: 0.14)
            : scheme.primary.withValues(alpha: 0),
        padding: EdgeInsets.fromLTRB(
          12,
          widget.startsGroup ? 10 : 2,
          12,
          widget.endsGroup ? 2 : 0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxBubble = min(constraints.maxWidth * 0.84, 460.0);
            return Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (widget.isGroup && !isMine && widget.startsGroup)
                  Padding(
                    padding: EdgeInsets.only(left: indent + 4, bottom: 3),
                    child: Text(
                      widget.sender.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: PersonTone.of(
                          widget.sender.id,
                          scheme,
                        ).foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                _SwipeToReply(
                  enabled: canAct && widget.canReply,
                  onReply: widget.onReply,
                  child: Row(
                    mainAxisAlignment: isMine
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (_showAvatarColumn) ...[
                        widget.endsGroup
                            ? UserAvatar(user: widget.sender, size: _avatarSize)
                            : const SizedBox(width: _avatarSize),
                        const SizedBox(width: _avatarGap),
                      ],
                      if (isMine) actions,
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxBubble),
                          child: GestureDetector(
                            onLongPress: canAct ? widget.onActions : null,
                            onSecondaryTap: canAct ? widget.onActions : null,
                            child: _Bubble(
                              message: message,
                              isMine: isMine,
                              startsGroup: widget.startsGroup,
                              endsGroup: widget.endsGroup,
                              quoted: widget.quoted,
                              quotedSenderLabel: widget.quotedSenderLabel,
                              onQuoteTap: widget.onQuoteTap,
                            ),
                          ),
                        ),
                      ),
                      if (!isMine) actions,
                    ],
                  ),
                ),
                if (message.reactions.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: indent, top: 4),
                    child: _ReactionRow(
                      message: message,
                      myId: widget.myId,
                      alignEnd: isMine,
                      onToggle: widget.onToggleReaction,
                    ),
                  ),
                // Every failed message offers this, not only the last of a group.
                if (message.status.needsAttention)
                  _FailedActions(
                    status: message.status,
                    onRetry: widget.onRetry,
                    onEdit: widget.onEdit,
                  ),
                if (widget.endsGroup)
                  Padding(
                    padding: EdgeInsets.only(
                      left: indent + 4,
                      right: 4,
                      top: 4,
                      bottom: 6,
                    ),
                    child: _Meta(message: message, isMine: isMine),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.isMine,
    required this.startsGroup,
    required this.endsGroup,
    this.quoted,
    this.quotedSenderLabel,
    this.onQuoteTap,
  });

  final Message message;
  final bool isMine;
  final bool startsGroup;
  final bool endsGroup;
  final Message? quoted;
  final String? quotedSenderLabel;
  final VoidCallback? onQuoteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const round = Radius.circular(20);
    const tight = Radius.circular(6);

    // Corners on the sender's side tighten where bubbles of a group meet.
    final top = startsGroup ? round : tight;
    final bottom = endsGroup ? round : tight;
    final radius = BorderRadius.only(
      topLeft: isMine ? round : top,
      bottomLeft: isMine ? round : bottom,
      topRight: isMine ? top : round,
      bottomRight: isMine ? bottom : round,
    );

    if (message.isDeleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          'Message deleted',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final foreground = isMine ? scheme.onPrimary : scheme.onSurface;
    final text = Text(
      message.text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: foreground,
        fontSize: 15,
        height: 1.32,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isMine ? scheme.primary : scheme.raised,
        borderRadius: radius,
      ),
      child: message.replyToId == null
          ? text
          : IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Quote(
                    quoted: quoted,
                    senderLabel: quotedSenderLabel,
                    foreground: foreground,
                    onTap: onQuoteTap,
                  ),
                  const SizedBox(height: 6),
                  text,
                ],
              ),
            ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({
    required this.quoted,
    required this.senderLabel,
    required this.foreground,
    this.onTap,
  });

  final Message? quoted;
  final String? senderLabel;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quoted = this.quoted;
    final isGone = quoted == null || quoted.isDeleted;
    return GestureDetector(
      onTap: isGone ? null : onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: foreground, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (senderLabel != null)
              Text(
                senderLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              isGone ? 'Message deleted' : quoted.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: foreground.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionRow extends StatelessWidget {
  const _ReactionRow({
    required this.message,
    required this.myId,
    required this.alignEnd,
    required this.onToggle,
  });

  final Message message;
  final String myId;
  final bool alignEnd;
  final ValueChanged<ReactionKind> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
      children: [
        for (final entry in message.reactions.entries)
          Builder(
            builder: (context) {
              final isMine = entry.value.contains(myId);
              final color = isMine
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant;
              return Semantics(
                button: true,
                selected: isMine,
                label: '${reactionLabel(entry.key)}, ${entry.value.length}',
                child: Material(
                  color: isMine ? scheme.primaryContainer : scheme.raised,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isMine ? scheme.primary : Colors.transparent,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onToggle(entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              reactionIcon(entry.key),
                              size: 14,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.value.length}',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

const _rejectedLabel = 'Not sent';
const _unconfirmedLabel = 'May not have sent';
const _rejectedIcon = Icons.error_outline_rounded;
const _unconfirmedIcon = Icons.help_outline_rounded;

class _FailedActions extends StatelessWidget {
  const _FailedActions({
    required this.status,
    required this.onRetry,
    required this.onEdit,
  });

  final MessageStatus status;
  final VoidCallback? onRetry;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
    final isUnconfirmed = status == MessageStatus.unconfirmed;
    return Semantics(
      liveRegion: true,
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            isUnconfirmed ? _unconfirmedIcon : _rejectedIcon,
            size: 15,
            color: scheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            isUnconfirmed ? _unconfirmedLabel : _rejectedLabel,
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.error),
          ),
          TextButton(
            onPressed: onRetry,
            style: style,
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: onEdit,
            style: style,
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, label) = switch (message.status) {
      MessageStatus.sending => (Icons.schedule_rounded, 'Sending'),
      MessageStatus.sent => (Icons.check_rounded, 'Sent'),
      MessageStatus.read => (Icons.done_all_rounded, 'Read'),
      MessageStatus.failed => (_rejectedIcon, _rejectedLabel),
      MessageStatus.unconfirmed => (_unconfirmedIcon, _unconfirmedLabel),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatClock(message.sentAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isMine && !message.isDeleted) ...[
          const SizedBox(width: 4),
          Icon(
            icon,
            size: 14,
            semanticLabel: label,
            color: switch (message.status) {
              MessageStatus.read => scheme.primary,
              MessageStatus.failed || MessageStatus.unconfirmed => scheme.error,
              _ => scheme.onSurfaceVariant,
            },
          ),
        ],
      ],
    );
  }
}

/// Drag a message to the right to reply to it.
class _SwipeToReply extends StatefulWidget {
  const _SwipeToReply({
    required this.enabled,
    required this.onReply,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onReply;
  final Widget child;

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply>
    with SingleTickerProviderStateMixin {
  static const _trigger = 56.0;
  static const _limit = 76.0;

  late final AnimationController _offset = AnimationController(
    vsync: this,
    upperBound: _limit,
    duration: const Duration(milliseconds: 180),
  );
  bool _armed = false;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails details) {
    _offset.value += details.primaryDelta ?? 0;
    final armed = _offset.value >= _trigger;
    if (armed && !_armed) HapticFeedback.selectionClick();
    _armed = armed;
  }

  void _onEnd([DragEndDetails? _]) {
    if (_armed) widget.onReply();
    _armed = false;
    _offset.animateBack(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: widget.enabled ? _onUpdate : null,
      onHorizontalDragEnd: widget.enabled ? _onEnd : null,
      onHorizontalDragCancel: widget.enabled ? _onEnd : null,
      child: AnimatedBuilder(
        animation: _offset,
        child: widget.child,
        builder: (context, child) {
          final progress = (_offset.value / _trigger).clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (progress > 0)
                Opacity(
                  opacity: progress,
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * progress,
                    child: Icon(
                      Icons.reply_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(_offset.value, 0),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}
