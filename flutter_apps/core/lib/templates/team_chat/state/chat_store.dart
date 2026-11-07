import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/chat_repository.dart';
import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'chat_navigation.dart';

enum ConversationFilter { all, unread, groups }

/// App-wide state: what the repository streams, plus what only the UI knows,
/// such as drafts, the message being replied to, and the current search.
class ChatStore extends ChangeNotifier {
  ChatStore(this.repository) {
    navigation.addListener(notifyListeners);
    _subscribe();
  }

  /// How long a send may go unanswered before its outcome counts as unknown.
  static const sendTimeout = Duration(seconds: 30);

  /// How long leaving may go unanswered before it counts as failed.
  static const leaveTimeout = Duration(seconds: 30);

  final ChatRepository repository;
  final ChatNavigation navigation = ChatNavigation();

  final _subscriptions = <StreamSubscription<Object?>>[];
  final _drafts = <String, String>{};
  final _replyTargets = <String, Message>{};

  /// Messages the repository has not confirmed in its stream yet, oldest
  /// first, by conversation id. Lists are replaced, never mutated.
  final _outbox = <String, List<Message>>{};

  /// What each outbox message quotes, by message id, for editing it later.
  final _outboxReplyTargets = <String, Message>{};

  /// Names of the streams whose last event was an error.
  final _failedStreams = <String>{};

  /// Conversations with a leave request in progress.
  final _leaving = <String>{};

  Map<String, ChatUser> _users = const {};
  List<Conversation> _conversations = const [];
  Map<String, Set<String>> _typing = const {};

  bool _isReady = false;
  bool _isDisposed = false;
  ConversationFilter _filter = ConversationFilter.all;
  String _query = '';
  List<Message> _messageHits = const [];
  Timer? _searchDebounce;
  int _nextClientId = 0;
  String? _actionError;

  /// False until the first conversation list arrives.
  bool get isReady => _isReady;

  /// True while a repository stream is failing, until it emits again.
  bool get hasSyncError => _failedStreams.isNotEmpty;
  ConversationFilter get filter => _filter;
  String get query => _query;
  bool get isSearching => _query.trim().isNotEmpty;
  List<Message> get messageHits => _messageHits;

  ChatUser get me => repository.currentUser;

  /// Pinned first, then most recently active.
  List<Conversation> get conversations {
    return [..._conversations]..sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  List<Conversation> get filteredConversations {
    return switch (_filter) {
      ConversationFilter.all => conversations,
      ConversationFilter.unread =>
        conversations.where((c) => unreadCount(c) > 0).toList(),
      ConversationFilter.groups =>
        conversations.where((c) => c.isGroup).toList(),
    };
  }

  /// Conversations whose title or members match the search.
  List<Conversation> get conversationHits {
    final needle = _query.trim().toLowerCase();
    return conversations.where((conversation) {
      if (titleOf(conversation).toLowerCase().contains(needle)) return true;
      return membersOf(conversation).any(
        (user) => user.id != me.id && user.name.toLowerCase().contains(needle),
      );
    }).toList();
  }

  /// Teammates matching the search that have no direct thread yet.
  List<ChatUser> get peopleHits {
    final needle = _query.trim().toLowerCase();
    return teammates
        .where(
          (user) =>
              user.name.toLowerCase().contains(needle) &&
              directThreadWith(user.id) == null,
        )
        .toList();
  }

  /// Everyone but the current user, sorted by name.
  List<ChatUser> get teammates {
    return _users.values.where((user) => user.id != me.id).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<ChatUser> get onlineTeammates {
    return teammates.where((u) => u.presence == Presence.online).toList();
  }

  /// Conversations with something unread, not counting muted ones.
  int get unreadConversations {
    return _conversations.where((c) => !c.isMuted && unreadCount(c) > 0).length;
  }

  int unreadCount(Conversation conversation) {
    return conversation.id == navigation.selectedId
        ? 0
        : conversation.unreadCount;
  }

  Conversation? conversation(String id) {
    for (final conversation in _conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  Conversation? directThreadWith(String userId) {
    for (final conversation in _conversations) {
      if (!conversation.isGroup && conversation.memberIds.contains(userId)) {
        return conversation;
      }
    }
    return null;
  }

  ChatUser user(String id) {
    return _users[id] ?? ChatUser(id: id, name: 'Unknown', role: '');
  }

  List<ChatUser> membersOf(Conversation conversation) {
    return conversation.memberIds.map(user).toList();
  }

  /// The other person of a direct thread.
  ChatUser partnerOf(Conversation conversation) {
    return user(conversation.memberIds.firstWhere((id) => id != me.id));
  }

  String titleOf(Conversation conversation) {
    if (!conversation.isGroup) return partnerOf(conversation).name;
    final title = conversation.title;
    if (title != null && title.isNotEmpty) return title;
    return conversation.memberIds
        .where((id) => id != me.id)
        .map((id) => user(id).firstName)
        .join(', ');
  }

  String senderLabel(String userId) {
    return userId == me.id ? 'You' : user(userId).firstName;
  }

  /// People typing in a conversation, excluding the current user.
  List<ChatUser> typingIn(String conversationId) {
    final ids = _typing[conversationId] ?? const <String>{};
    return ids.where((id) => id != me.id).map(user).toList();
  }

  String? typingLabel(String conversationId) {
    final people = typingIn(conversationId);
    return switch (people.length) {
      0 => null,
      1 => '${people.single.firstName} is typing',
      _ => '${people.length} people are typing',
    };
  }

  String draft(String conversationId) => _drafts[conversationId] ?? '';

  void setDraft(String conversationId, String text) {
    if (draft(conversationId) == text) return;
    if (text.isEmpty) {
      _drafts.remove(conversationId);
    } else {
      _drafts[conversationId] = text;
    }
    notifyListeners();
  }

  Message? replyTarget(String conversationId) => _replyTargets[conversationId];

  void setReplyTarget(Message message) {
    _replyTargets[message.conversationId] = message;
    notifyListeners();
  }

  void clearReplyTarget(String conversationId) {
    if (_replyTargets.remove(conversationId) != null) notifyListeners();
  }

  /// Messages still sending, or whose send ended without a confirmation.
  /// `ThreadController` shows these after what the stream delivers.
  List<Message> outbox(String conversationId) {
    return _outbox[conversationId] ?? const [];
  }

  int failedCount(String conversationId) {
    return outbox(
      conversationId,
    ).where((m) => m.status == MessageStatus.failed).length;
  }

  int unconfirmedCount(String conversationId) {
    return outbox(
      conversationId,
    ).where((m) => m.status == MessageStatus.unconfirmed).length;
  }

  /// True for a message the repository hasn't confirmed yet, so it can't be
  /// reacted to or quoted.
  bool isUnsent(Message message) {
    return outbox(
      message.conversationId,
    ).any((m) => m.id == message.id && m.status != MessageStatus.sent);
  }

  /// Drops outbox messages that the stream now delivers as [ids].
  void acknowledge(String conversationId, Iterable<String> ids) {
    final known = ids.toSet();
    final pending = outbox(conversationId);
    if (!pending.any((m) => known.contains(m.id))) return;
    _setOutbox(conversationId, [
      for (final message in pending)
        if (!known.contains(message.id)) message,
    ]);
    _outboxReplyTargets.removeWhere((id, _) => known.contains(id));
    notifyListeners();
  }

  /// The last failed background action, for the app to show once.
  String? takeActionError() {
    final error = _actionError;
    _actionError = null;
    return error;
  }

  /// Runs a repository call nobody awaits. With a [failure] message, the app
  /// shows it as a snack bar when the call fails. Without one, a failure is
  /// only logged.
  Future<void> runAction(
    Future<void> Function() action, {
    String? failure,
  }) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('Chat action failed: $error\n$stackTrace');
      if (_isDisposed || failure == null) return;
      _actionError = failure;
      notifyListeners();
    }
  }

  /// Subscribes to every stream again, after [hasSyncError].
  void reconnect() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _failedStreams.clear();
    _subscribe();
    notifyListeners();
  }

  void setFilter(ConversationFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setQuery(String query) {
    _query = query;
    _searchDebounce?.cancel();
    if (!isSearching) {
      _messageHits = const [];
      notifyListeners();
      return;
    }
    notifyListeners();
    _searchDebounce = Timer(const Duration(milliseconds: 180), () async {
      final term = query.trim();
      await runAction(() async {
        final hits = await repository.searchMessages(term);
        if (_isDisposed || _query.trim() != term) return;
        _messageHits = hits;
        notifyListeners();
      }, failure: 'Could not search messages.');
    });
  }

  void openConversation(String id, {String? focusMessageId}) {
    final count = conversation(id)?.unreadCount ?? 0;
    navigation.openThread(
      id,
      focusMessageId: focusMessageId,
      unreadCount: count,
    );
    runAction(() => repository.markRead(id));
  }

  /// Opens the direct thread with [userId], creating it if needed.
  Future<void> openDirectThread(String userId) {
    return runAction(() async {
      final conversation = await repository.createConversation(
        memberIds: [userId],
      );
      if (!_isDisposed) openConversation(conversation.id);
    }, failure: 'Could not open the conversation.');
  }

  Future<void> createGroup(List<String> memberIds, String? title) {
    return runAction(() async {
      final conversation = await repository.createConversation(
        memberIds: memberIds,
        title: title,
      );
      if (!_isDisposed) openConversation(conversation.id);
    }, failure: 'Could not create the group.');
  }

  /// Puts the message in the outbox and sends it. The text and reply target
  /// move from the composer to the outbox message, so a failed send loses
  /// neither. Starter chips send other text, which leaves the draft alone.
  void send(String conversationId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final replyTo = _replyTargets.remove(conversationId);
    if (draft(conversationId).trim() == trimmed) {
      _drafts.remove(conversationId);
    }
    final now = DateTime.now();
    final message = Message(
      id: '${me.id}-${now.microsecondsSinceEpoch}-${_nextClientId++}',
      conversationId: conversationId,
      senderId: me.id,
      text: trimmed,
      sentAt: now,
      replyToId: replyTo?.id,
      status: MessageStatus.sending,
    );
    if (replyTo != null) _outboxReplyTargets[message.id] = replyTo;
    _setOutbox(conversationId, [...outbox(conversationId), message]);
    notifyListeners();
    _deliver(message);
  }

  /// Sends a failed or unconfirmed message again, with the same client id so
  /// a send that worked but lost its response isn't posted twice.
  void retry(Message message) {
    if (!(_outboxStatus(message)?.needsAttention ?? false)) return;
    final sending = message.copyWith(status: MessageStatus.sending);
    _replaceInOutbox(message, sending);
    notifyListeners();
    _deliver(sending);
  }

  /// Moves a failed message back into the composer, after any text already
  /// there, along with the message it was replying to.
  ///
  /// Sending the edit makes a new message, so an [MessageStatus.unconfirmed]
  /// one that did arrive ends up posted twice. It only moves once the user has
  /// been warned of that and [acceptDuplicateRisk] is true.
  void editFailed(Message message, {bool acceptDuplicateRisk = false}) {
    final status = _outboxStatus(message);
    if (status == null || !status.needsAttention) return;
    if (status == MessageStatus.unconfirmed && !acceptDuplicateRisk) return;
    final conversationId = message.conversationId;
    final replyTo = _outboxReplyTargets.remove(message.id);
    final current = draft(conversationId);
    _drafts[conversationId] = current.isEmpty
        ? message.text
        : '$current\n${message.text}';
    if (replyTo != null) _replyTargets[conversationId] ??= replyTo;
    _replaceInOutbox(message, null);
    notifyListeners();
  }

  void toggleReaction(Message message, ReactionKind kind) {
    runAction(
      () => repository.toggleReaction(
        conversationId: message.conversationId,
        messageId: message.id,
        kind: kind,
      ),
      failure: 'Could not update the reaction.',
    );
  }

  /// Deletes a message. A failed one never reached the repository, so it is
  /// only dropped from the outbox. An unconfirmed one may have, so it is
  /// deleted there first, and its row stays if that fails.
  void deleteMessage(Message message) {
    final status = _outboxStatus(message);
    if (status == MessageStatus.failed) {
      _dropFromOutbox(message);
      notifyListeners();
      return;
    }
    runAction(() async {
      await repository.deleteMessage(
        conversationId: message.conversationId,
        messageId: message.id,
      );
      if (_isDisposed) return;
      if (_replyTargets[message.conversationId]?.id == message.id) {
        clearReplyTarget(message.conversationId);
      }
      // A retry during the call owns the row now.
      if (status != MessageStatus.unconfirmed ||
          _outboxStatus(message) != MessageStatus.unconfirmed) {
        return;
      }
      _dropFromOutbox(message);
      notifyListeners();
    }, failure: 'Could not delete the message.');
  }

  /// Leaves the conversation and returns whether that worked. The thread, its
  /// draft, reply target and unsent messages stay until the repository agrees,
  /// so a refused leave costs nothing. A second call while one runs is ignored.
  Future<bool> leave(String conversationId) async {
    if (!_leaving.add(conversationId)) return false;
    try {
      await repository.leaveConversation(conversationId).timeout(leaveTimeout);
    } catch (error, stackTrace) {
      debugPrint('Leaving failed: $error\n$stackTrace');
      if (_isDisposed) return false;
      // The answer was lost, but the stream shows the leave went through.
      if (conversation(conversationId) != null) {
        _actionError = 'Could not leave the conversation.';
        notifyListeners();
        return false;
      }
    } finally {
      _leaving.remove(conversationId);
    }
    if (_isDisposed) return true;
    _forget(conversationId);
    notifyListeners();
    return true;
  }

  void _forget(String conversationId) {
    // In two panes another thread may have been opened during the call.
    if (navigation.selectedId == conversationId) navigation.closeThread();
    _drafts.remove(conversationId);
    _replyTargets.remove(conversationId);
    for (final message in outbox(conversationId)) {
      _outboxReplyTargets.remove(message.id);
    }
    _outbox.remove(conversationId);
  }

  /// The status of [message] in the outbox, or null if it isn't there.
  MessageStatus? _outboxStatus(Message message) {
    for (final pending in outbox(message.conversationId)) {
      if (pending.id == message.id) return pending.status;
    }
    return null;
  }

  void _dropFromOutbox(Message message) {
    _outboxReplyTargets.remove(message.id);
    _replaceInOutbox(message, null);
  }

  void _setOutbox(String conversationId, List<Message> messages) {
    if (messages.isEmpty) {
      _outbox.remove(conversationId);
    } else {
      _outbox[conversationId] = List.unmodifiable(messages);
    }
  }

  /// Swaps [original] for [replacement] in the outbox, or removes it. Does
  /// nothing if it is gone, as it is once acknowledged or after leaving.
  void _replaceInOutbox(Message original, Message? replacement) {
    final conversationId = original.conversationId;
    final pending = outbox(conversationId);
    if (!pending.any((m) => m.id == original.id)) return;
    _setOutbox(conversationId, [
      for (final message in pending)
        if (message.id != original.id) message else ?replacement,
    ]);
  }

  Future<void> _deliver(Message message) async {
    try {
      final sent = await repository
          .sendMessage(
            conversationId: message.conversationId,
            text: message.text,
            replyToId: message.replyToId,
            clientMessageId: message.id,
          )
          .timeout(sendTimeout);
      if (_isDisposed) return;
      // Stays visible as sent until the stream delivers it, so the row doesn't
      // blink out if the stream is slower than this response.
      _outboxReplyTargets.remove(message.id);
      _replaceInOutbox(message, sent.copyWith(status: MessageStatus.sent));
    } on MessageRejectedException catch (error) {
      debugPrint('Message rejected: $error');
      if (_isDisposed) return;
      _replaceInOutbox(message, message.copyWith(status: MessageStatus.failed));
    } catch (error, stackTrace) {
      // The stream clears the row if the message turns out to have arrived.
      debugPrint('Message outcome unknown: $error\n$stackTrace');
      if (_isDisposed) return;
      _replaceInOutbox(
        message,
        message.copyWith(status: MessageStatus.unconfirmed),
      );
    }
    notifyListeners();
  }

  void _subscribe() {
    _subscriptions
      ..add(_watch<List<ChatUser>>('users', repository.watchUsers(), _onUsers))
      ..add(
        _watch<List<Conversation>>(
          'conversations',
          repository.watchConversations(),
          _onConversations,
        ),
      )
      ..add(
        _watch<Map<String, Set<String>>>(
          'typing',
          repository.watchTyping(),
          _onTyping,
        ),
      );
  }

  StreamSubscription<T> _watch<T>(
    String name,
    Stream<T> stream,
    void Function(T) onData,
  ) {
    return stream.listen(
      (value) {
        _failedStreams.remove(name);
        onData(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Chat stream "$name" failed: $error\n$stackTrace');
        _failedStreams.add(name);
        notifyListeners();
      },
    );
  }

  void _onUsers(List<ChatUser> users) {
    _users = {for (final user in users) user.id: user};
    notifyListeners();
  }

  void _onConversations(List<Conversation> conversations) {
    final open = navigation.selectedId;
    final wasListed = open != null && conversation(open) != null;
    _conversations = conversations;
    _isReady = true;
    // The server has confirmed this one is gone, for example after a leave
    // whose answer was lost. A new thread can open before it is listed, so
    // only a thread that was listed counts.
    if (wasListed && conversation(open) == null) _forget(open);
    if (open != null && (conversation(open)?.unreadCount ?? 0) > 0) {
      runAction(() => repository.markRead(open));
    }
    notifyListeners();
  }

  void _onTyping(Map<String, Set<String>> typing) {
    _typing = typing;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    navigation.dispose();
    super.dispose();
  }
}
