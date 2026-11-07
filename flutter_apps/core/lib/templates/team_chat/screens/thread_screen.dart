import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../state/chat_scope.dart';
import '../state/chat_store.dart';
import '../state/thread_controller.dart';
import '../widgets/avatars.dart';
import '../widgets/chat_header.dart';
import '../widgets/composer.dart';
import '../widgets/empty_state.dart';
import '../widgets/message_actions_sheet.dart';
import '../widgets/message_row.dart';
import '../widgets/sync_banner.dart';
import '../widgets/thread_markers.dart';
import '../widgets/typing_indicator.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({
    super.key,
    required this.conversationId,
    this.showBack = true,
  });

  final String conversationId;
  final bool showBack;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final _scrollController = ScrollController();
  final _composerFocus = FocusNode(debugLabel: 'composer');
  final _messageKeys = <String, GlobalKey>{};

  late final ChatStore _store = ChatScope.read(context);
  late final ThreadController _thread = ThreadController(
    store: _store,
    conversationId: widget.conversationId,
    unreadCount: _store.navigation.unreadAtOpen,
  );

  Timer? _highlightTimer;
  String? _highlightedId;
  bool _showJumpButton = false;
  int _lastCount = 0;
  bool _didFocusMessage = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _thread.addListener(_onThreadChanged);
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _thread.removeListener(_onThreadChanged);
    _thread.dispose();
    _scrollController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 240;
    if (show != _showJumpButton) setState(() => _showJumpButton = show);
  }

  void _onThreadChanged() {
    final items = _thread.items;
    final newest = items.whereType<MessageItem>().firstOrNull?.message;
    final grew = items.length > _lastCount && _lastCount > 0;
    _lastCount = items.length;

    if (grew && newest?.senderId == _store.me.id) _scrollToLatest();

    final focusId = _store.navigation.focusMessageId;
    if (focusId != null && !_didFocusMessage && items.isNotEmpty) {
      _didFocusMessage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _revealMessage(focusId);
      });
    }
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  /// Scrolls to a message that may not be built yet. The list is lazy, so it
  /// pages toward older messages until the row exists.
  Future<void> _revealMessage(String id) async {
    for (var attempt = 0; attempt < 60; attempt++) {
      if (!mounted || !_scrollController.hasClients) return;
      final rowContext = _messageKeys[id]?.currentContext;
      if (rowContext != null && rowContext.mounted) {
        await Scrollable.ensureVisible(
          rowContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
        _highlight(id);
        return;
      }
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent) return;
      _scrollController.jumpTo(
        min(
          position.pixels + position.viewportDimension * 0.8,
          position.maxScrollExtent,
        ),
      );
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _highlight(String id) {
    if (!mounted) return;
    setState(() => _highlightedId = id);
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _highlightedId = null);
    });
  }

  void _reply(Message message) {
    _store.setReplyTarget(message);
    _composerFocus.requestFocus();
  }

  /// Moves an unsent message to the composer. If it may have arrived after
  /// all, the user first has to accept that the edit could post a second copy.
  Future<void> _edit(Message message) async {
    if (message.status == MessageStatus.unconfirmed) {
      final confirmed = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit this message?'),
            content: const Text(
              'It may already have been delivered. If it was, sending your '
              'edit posts a second message. Retry sends it again without '
              'that risk.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Edit anyway'),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !mounted) return;
    }
    _store.editFailed(message, acceptDuplicateRisk: true);
    _composerFocus.requestFocus();
  }

  void _reconnect() {
    _thread.reconnect();
    if (_store.hasSyncError) _store.reconnect();
  }

  void _showActions(Message message) {
    final isUnsent = _store.isUnsent(message);
    showMessageActions(
      context,
      message: message,
      myId: _store.me.id,
      canDelete:
          message.senderId == _store.me.id &&
          (!isUnsent || message.status.needsAttention),
      canRespond: !isUnsent,
      onReact: (kind) => _store.toggleReaction(message, kind),
      onReply: () => _reply(message),
      onCopy: () {
        Clipboard.setData(ClipboardData(text: message.text));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Copied')));
      },
      onDelete: () => _store.deleteMessage(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final conversation = store.conversation(widget.conversationId);

    // The conversation can vanish while this screen animates out after leaving.
    if (conversation == null) return const Scaffold();

    final typing = store.typingIn(conversation.id);
    final replyTo = store.replyTarget(conversation.id);

    return Scaffold(
      body: Column(
        children: [
          _ThreadHeader(conversation: conversation, showBack: widget.showBack),
          Expanded(
            child: ListenableBuilder(
              listenable: _thread,
              builder: (context, _) {
                final hasRows = _thread.items.isNotEmpty;
                if (_thread.hasError && !hasRows) {
                  return EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Could not load messages',
                    message: 'Check your connection and try again.',
                    action: FilledButton(
                      onPressed: _reconnect,
                      child: const Text('Try again'),
                    ),
                  );
                }
                if (_thread.isLoading && !hasRows) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    if (_thread.hasError || store.hasSyncError)
                      SyncBanner(onRetry: _reconnect),
                    Expanded(
                      child: _thread.items.whereType<MessageItem>().isEmpty
                          ? _EmptyThread(conversation: conversation)
                          : Stack(
                              children: [
                                _buildList(store, conversation),
                                Positioned(
                                  right: 12,
                                  bottom: 10,
                                  child: _JumpButton(
                                    visible: _showJumpButton,
                                    onPressed: _scrollToLatest,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomLeft,
            child: typing.isEmpty
                ? const SizedBox(width: double.infinity)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: TypingIndicator(
                      people: typing,
                      showAvatar: conversation.isGroup,
                    ),
                  ),
          ),
          Composer(
            initialText: store.draft(conversation.id),
            hintText: conversation.isGroup
                ? 'Message ${store.titleOf(conversation)}'
                : 'Message ${store.partnerOf(conversation).firstName}',
            focusNode: _composerFocus,
            replyTo: replyTo,
            replyToLabel: replyTo == null
                ? null
                : store.senderLabel(replyTo.senderId),
            onChanged: (text) => store.setDraft(conversation.id, text),
            onSend: (text) => store.send(conversation.id, text),
            onCancelReply: () => store.clearReplyTarget(conversation.id),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ChatStore store, Conversation conversation) {
    final items = _thread.items;
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      itemCount: items.length,
      findChildIndexCallback: (key) {
        return key is ValueKey<String> ? _thread.indexOfKey(key.value) : null;
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return KeyedSubtree(
          key: ValueKey(item.key),
          child: switch (item) {
            DayItem(:final day) => DateSeparator(day: day),
            UnreadItem() => const UnreadDivider(),
            EventItem(:final message) => EventLine(text: message.text),
            MessageItem() => _EntranceAnimation(
              animate: _thread.takeFresh(item.message.id),
              alignEnd: item.message.senderId == store.me.id,
              child: _buildMessage(store, conversation, item),
            ),
          },
        );
      },
    );
  }

  Widget _buildMessage(
    ChatStore store,
    Conversation conversation,
    MessageItem item,
  ) {
    final message = item.message;
    final quoted = item.quoted;
    return MessageRow(
      key: _messageKeys.putIfAbsent(message.id, GlobalKey.new),
      message: message,
      sender: store.user(message.senderId),
      isMine: message.senderId == store.me.id,
      isGroup: conversation.isGroup,
      startsGroup: item.startsGroup,
      endsGroup: item.endsGroup,
      myId: store.me.id,
      quoted: quoted,
      quotedSenderLabel: quoted == null
          ? null
          : store.senderLabel(quoted.senderId),
      isHighlighted: message.id == _highlightedId,
      onQuoteTap: quoted == null ? null : () => _revealMessage(quoted.id),
      onActions: () => _showActions(message),
      onReply: () => _reply(message),
      onToggleReaction: (kind) => store.toggleReaction(message, kind),
      canReply: !store.isUnsent(message),
      onRetry: () => store.retry(message),
      onEdit: () => _edit(message),
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({required this.conversation, required this.showBack});

  final Conversation conversation;
  final bool showBack;

  String _status(ChatStore store) {
    if (conversation.isGroup) {
      return '${conversation.memberIds.length} members';
    }
    final partner = store.partnerOf(conversation);
    return switch (partner.presence) {
      Presence.online => 'Online',
      Presence.away => 'Away',
      Presence.offline => partner.role,
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typing = store.typingLabel(conversation.id);

    return ChatHeader(
      leading: showBack
          ? IconButton(
              tooltip: 'Back',
              onPressed: store.navigation.closeThread,
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      trailing: IconButton(
        tooltip: conversation.isGroup ? 'Group info' : 'Conversation info',
        onPressed: store.navigation.openInfo,
        icon: const Icon(Icons.info_outline_rounded),
      ),
      child: InkWell(
        onTap: store.navigation.openInfo,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              ConversationAvatar(conversation: conversation, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      store.titleOf(conversation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      typing ?? _status(store),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: typing == null
                            ? scheme.onSurfaceVariant
                            : scheme.primary,
                        fontWeight: typing == null ? null : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread({required this.conversation});

  final Conversation conversation;

  static const _starters = ['Hey!', 'Do you have a minute?', 'Quick question'];

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final name = conversation.isGroup
        ? store.titleOf(conversation)
        : store.partnerOf(conversation).firstName;
    return EmptyState(
      icon: Icons.waving_hand_rounded,
      title: 'Say hello',
      message: conversation.isGroup
          ? 'This is the start of $name.'
          : 'This is the start of your conversation with $name.',
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final text in _starters)
            ActionChip(
              label: Text(text),
              onPressed: () => store.send(conversation.id, text),
            ),
        ],
      ),
    );
  }
}

class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedScale(
        scale: visible ? 1 : 0.6,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 120),
          child: IconButton.filled(
            tooltip: 'Jump to latest',
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: scheme.inverseSurface,
              foregroundColor: scheme.onInverseSurface,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ),
    );
  }
}

/// Slides a new message up from the composer. Rows that were already there
/// pass [animate] as false and appear without motion.
class _EntranceAnimation extends StatefulWidget {
  const _EntranceAnimation({
    required this.animate,
    required this.alignEnd,
    required this.child,
  });

  final bool animate;
  final bool alignEnd;
  final Widget child;

  @override
  State<_EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<_EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: widget.animate ? 0 : 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SizeTransition(
        sizeFactor: _curve,
        alignment: widget.alignEnd
            ? Alignment.bottomRight
            : Alignment.bottomLeft,
        child: widget.child,
      ),
    );
  }
}
