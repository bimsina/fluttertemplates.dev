import 'dart:async';
import 'dart:math';

import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'chat_repository.dart';
import 'seed_data.dart';

/// The ways [FakeChatRepository.nextSendFault] can make a send go wrong.
enum FakeSendFault {
  /// Refused: nothing is stored and [MessageRejectedException] is thrown.
  rejected,

  /// The message is stored, then the response is lost.
  responseLost,
}

/// In-memory backend. Teammates "reply" on timers so the demo feels alive:
/// each message you send triggers a typing indicator and then an answer.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({Random? random, bool ambientActivity = true})
    : _random = random ?? Random() {
    for (final user in seedUsers) {
      _users[user.id] = user;
    }
    for (final seed in buildSeedConversations(DateTime.now())) {
      _conversations[seed.conversation.id] = seed.conversation;
      _messages[seed.conversation.id] = seed.messages;
    }
    if (ambientActivity) _scheduleAmbientMessage(const Duration(seconds: 14));
  }

  final Random _random;

  /// What goes wrong with the next [sendMessage] call, if anything. Set this
  /// to try the "Not sent" and "May not have sent" states.
  FakeSendFault? nextSendFault;

  final _users = <String, ChatUser>{};
  final _conversations = <String, Conversation>{};
  final _messages = <String, List<Message>>{};
  final _typing = <String, Set<String>>{};

  final _userChanges = StreamController<void>.broadcast();
  final _conversationChanges = StreamController<void>.broadcast();
  final _messageChanges = StreamController<String>.broadcast();
  final _typingChanges = StreamController<void>.broadcast();

  /// Every pending timer, so [dispose] can cancel them all.
  final _timers = <Timer>{};

  /// Timers of the reply in progress, so a follow-up message can restart it.
  final _replyTimers = <String, List<Timer>>{};

  var _nextId = 0;
  var _ambientIndex = 0;
  var _cannedIndex = 0;

  @override
  ChatUser get currentUser => _users[currentUserId]!;

  @override
  Stream<List<ChatUser>> watchUsers() {
    return _watch(_userChanges.stream, () => _users.values.toList());
  }

  @override
  Stream<List<Conversation>> watchConversations() {
    return _watch(
      _conversationChanges.stream,
      () => _conversations.values.toList(),
    );
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return _watch(
      _messageChanges.stream.where((id) => id == conversationId),
      () => List.unmodifiable(_messages[conversationId] ?? const <Message>[]),
    );
  }

  @override
  Stream<Map<String, Set<String>>> watchTyping() {
    return _watch(
      _typingChanges.stream,
      () => {
        for (final entry in _typing.entries)
          if (entry.value.isNotEmpty) entry.key: Set.of(entry.value),
      },
    );
  }

  /// Emits [read] on listen and again each time [changes] fires.
  Stream<T> _watch<T>(Stream<Object?> changes, T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<Object?>? subscription;
    controller = StreamController<T>(
      onListen: () {
        controller.add(read());
        subscription = changes.listen(
          (_) => controller.add(read()),
          onError: controller.addError,
        );
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String text,
    String? replyToId,
    String? clientMessageId,
  }) async {
    final fault = nextSendFault;
    nextSendFault = null;
    if (fault == FakeSendFault.rejected) {
      throw const MessageRejectedException('Refused by the fake backend.');
    }
    if (!_conversations.containsKey(conversationId)) {
      throw const MessageRejectedException('Conversation not found.');
    }
    final message = _commitMessage(
      conversationId: conversationId,
      text: text,
      replyToId: replyToId,
      clientMessageId: clientMessageId,
    );
    if (fault == FakeSendFault.responseLost) {
      throw TimeoutException('The response was lost.');
    }
    return message;
  }

  /// Stores a message, or returns the one already stored under the client id.
  Message _commitMessage({
    required String conversationId,
    required String text,
    String? replyToId,
    String? clientMessageId,
  }) {
    final id = clientMessageId ?? _newId('m');
    final existing = _messages[conversationId]?.where((m) => m.id == id);
    if (existing != null && existing.isNotEmpty) return existing.first;

    final message = Message(
      id: id,
      conversationId: conversationId,
      senderId: currentUserId,
      text: text,
      sentAt: DateTime.now(),
      replyToId: replyToId,
      status: MessageStatus.sending,
    );
    _append(message);
    _after(const Duration(milliseconds: 350), () {
      _updateMessage(
        conversationId,
        message.id,
        (m) => m.copyWith(status: MessageStatus.sent),
      );
    });
    _scheduleReplies(message);
    return message;
  }

  @override
  Future<void> toggleReaction({
    required String conversationId,
    required String messageId,
    required ReactionKind kind,
  }) async {
    _setReaction(conversationId, messageId, kind, currentUserId);
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    _updateMessage(
      conversationId,
      messageId,
      (m) => m.copyWith(text: '', isDeleted: true, reactions: const {}),
    );
  }

  @override
  Future<void> markRead(String conversationId) async {
    final conversation = _conversations[conversationId];
    if (conversation == null || conversation.unreadCount == 0) return;
    _conversations[conversationId] = conversation.copyWith(unreadCount: 0);
    _conversationChanges.add(null);
  }

  @override
  Future<Conversation> createConversation({
    required List<String> memberIds,
    String? title,
  }) async {
    final isGroup = memberIds.length > 1;
    if (!isGroup) {
      for (final conversation in _conversations.values) {
        if (!conversation.isGroup &&
            conversation.memberIds.contains(memberIds.single)) {
          return conversation;
        }
      }
    }
    final conversation = Conversation(
      id: _newId('c'),
      memberIds: [currentUserId, ...memberIds],
      createdAt: DateTime.now(),
      isGroup: isGroup,
      title: isGroup ? title : null,
    );
    _conversations[conversation.id] = conversation;
    _messages[conversation.id] = [];
    _conversationChanges.add(null);
    if (isGroup) _appendEvent(conversation.id, 'You created this group');
    return _conversations[conversation.id]!;
  }

  @override
  Future<void> renameGroup(String conversationId, String title) async {
    final conversation = _conversations[conversationId];
    if (conversation == null || conversation.title == title) return;
    _conversations[conversationId] = conversation.copyWith(title: title);
    _appendEvent(conversationId, 'You renamed the group to $title');
  }

  @override
  Future<void> addMembers(String conversationId, List<String> memberIds) async {
    final conversation = _conversations[conversationId];
    if (conversation == null || memberIds.isEmpty) return;
    _conversations[conversationId] = conversation.copyWith(
      memberIds: [...conversation.memberIds, ...memberIds],
    );
    final names = memberIds.map((id) => _users[id]!.firstName).join(', ');
    _appendEvent(conversationId, 'You added $names');
  }

  @override
  Future<void> setMuted(String conversationId, {required bool muted}) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    _conversations[conversationId] = conversation.copyWith(isMuted: muted);
    _conversationChanges.add(null);
  }

  @override
  Future<void> setPinned(String conversationId, {required bool pinned}) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) return;
    _conversations[conversationId] = conversation.copyWith(isPinned: pinned);
    _conversationChanges.add(null);
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    _cancelReplies(conversationId);
    _conversations.remove(conversationId);
    _messages.remove(conversationId);
    _conversationChanges.add(null);
    _messageChanges.add(conversationId);
  }

  @override
  Future<List<Message>> searchMessages(String query) async {
    final needle = query.toLowerCase();
    final hits = [
      for (final messages in _messages.values)
        for (final message in messages)
          if (!message.isSystem &&
              !message.isDeleted &&
              message.text.toLowerCase().contains(needle))
            message,
    ]..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return hits.take(20).toList();
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _replyTimers.clear();
    _userChanges.close();
    _conversationChanges.close();
    _messageChanges.close();
    _typingChanges.close();
  }

  // Writes

  String _newId(String prefix) => '$prefix-${_nextId++}';

  void _append(Message message) {
    final id = message.conversationId;
    final conversation = _conversations[id];
    if (conversation == null) return;
    _messages[id] = [...?_messages[id], message];
    final incoming = message.senderId != currentUserId && !message.isSystem;
    _conversations[id] = conversation.copyWith(
      lastMessage: () => message,
      unreadCount: conversation.unreadCount + (incoming ? 1 : 0),
    );
    _messageChanges.add(id);
    _conversationChanges.add(null);
  }

  void _appendEvent(String conversationId, String text) {
    _append(
      Message(
        id: _newId('e'),
        conversationId: conversationId,
        senderId: currentUserId,
        text: text,
        sentAt: DateTime.now(),
        isSystem: true,
      ),
    );
  }

  void _updateMessage(
    String conversationId,
    String messageId,
    Message Function(Message) update,
  ) {
    final messages = _messages[conversationId];
    final conversation = _conversations[conversationId];
    if (messages == null || conversation == null) return;
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    final updated = update(messages[index]);
    _messages[conversationId] = [...messages]..[index] = updated;
    _messageChanges.add(conversationId);
    if (conversation.lastMessage?.id == messageId) {
      _conversations[conversationId] = conversation.copyWith(
        lastMessage: () => updated,
      );
      _conversationChanges.add(null);
    }
  }

  void _setReaction(
    String conversationId,
    String messageId,
    ReactionKind kind,
    String userId,
  ) {
    _updateMessage(conversationId, messageId, (message) {
      final reactions = {
        for (final entry in message.reactions.entries)
          entry.key: Set.of(entry.value),
      };
      final people = reactions.putIfAbsent(kind, () => {});
      if (!people.remove(userId)) people.add(userId);
      if (people.isEmpty) reactions.remove(kind);
      return message.copyWith(reactions: reactions);
    });
  }

  void _setTyping(String conversationId, String userId, bool isTyping) {
    final people = _typing.putIfAbsent(conversationId, () => {});
    if (isTyping ? people.add(userId) : people.remove(userId)) {
      _typingChanges.add(null);
    }
  }

  void _setPresence(String userId, Presence presence) {
    final user = _users[userId];
    if (user == null || user.presence == presence) return;
    _users[userId] = user.copyWith(presence: presence);
    _userChanges.add(null);
  }

  // Simulated teammates

  Timer _after(Duration delay, void Function() action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      action();
    });
    _timers.add(timer);
    return timer;
  }

  void _cancelReplies(String conversationId) {
    for (final timer in _replyTimers.remove(conversationId) ?? const []) {
      timer.cancel();
      _timers.remove(timer);
    }
    final typing = _typing[conversationId];
    if (typing != null && typing.isNotEmpty) {
      typing.clear();
      _typingChanges.add(null);
    }
  }

  void _scheduleReplies(Message sent) {
    final id = sent.conversationId;
    final conversation = _conversations[id];
    if (conversation == null) return;

    // A quick follow-up restarts the reply, as it would with a real person.
    _cancelReplies(id);
    final timers = _replyTimers[id] = [];
    final others = conversation.memberIds
        .where((member) => member != currentUserId)
        .toList();
    if (others.isEmpty) return;
    others.shuffle(_random);
    final responders = others.take(
      conversation.isGroup && others.length > 1 && _random.nextBool() ? 2 : 1,
    );

    var delay = Duration(milliseconds: 700 + _random.nextInt(600));
    timers.add(
      _after(delay, () {
        _updateMessage(
          id,
          sent.id,
          (m) => m.copyWith(status: MessageStatus.read),
        );
      }),
    );

    for (final responder in responders) {
      final text = _cannedReply(sent.text);
      final quote = conversation.isGroup && _random.nextInt(3) == 0;
      timers.add(
        _after(delay, () {
          _setPresence(responder, Presence.online);
          _setTyping(id, responder, true);
        }),
      );
      delay += Duration(milliseconds: 1000 + text.length * 22);
      timers.add(
        _after(delay, () {
          _setTyping(id, responder, false);
          _append(
            Message(
              id: _newId('m'),
              conversationId: id,
              senderId: responder,
              text: text,
              sentAt: DateTime.now(),
              replyToId: quote ? sent.id : null,
            ),
          );
        }),
      );
      delay += const Duration(milliseconds: 500);
    }

    if (conversation.isGroup && _random.nextBool()) {
      final reactor = others.last;
      final kind = ReactionKind.values[_random.nextInt(3)];
      timers.add(
        _after(const Duration(milliseconds: 1500), () {
          _setReaction(id, sent.id, kind, reactor);
        }),
      );
    }
  }

  String _cannedReply(String text) {
    final lower = text.toLowerCase();
    final pool = _cannedReplies.entries
        .where((entry) => entry.key.hasMatch(lower))
        .map((entry) => entry.value)
        .firstOrNull;
    final replies = pool ?? _fallbackReplies;
    return replies[_cannedIndex++ % replies.length];
  }

  void _scheduleAmbientMessage(Duration delay) {
    _after(delay, () {
      if (_ambientIndex >= _ambientScript.length) return;
      final (conversationId, senderId, text) = _ambientScript[_ambientIndex++];
      final canPost =
          _conversations.containsKey(conversationId) &&
          !(_replyTimers[conversationId] ?? const []).any((t) => t.isActive);
      if (canPost) {
        _setTyping(conversationId, senderId, true);
        _after(const Duration(milliseconds: 2400), () {
          _setTyping(conversationId, senderId, false);
          _append(
            Message(
              id: _newId('m'),
              conversationId: conversationId,
              senderId: senderId,
              text: text,
              sentAt: DateTime.now(),
            ),
          );
        });
      }
      _scheduleAmbientMessage(const Duration(seconds: 32));
    });
  }
}

/// Unprompted messages that keep the conversation list moving during a demo.
const _ambientScript = <(String, String, String)>[
  ('dm-priya', 'priya', 'Could you send me the deck before the review?'),
  ('launch', 'kenji', 'Retested the invite link. It holds up on Android now.'),
  ('crit', 'sofia', 'Added the filled variants to the icon set too.'),
];

final _cannedReplies = <RegExp, List<String>>{
  RegExp(r'\b(thanks|thank you|thx|cheers)\b'): [
    'Any time.',
    'Happy to help.',
    'No problem at all.',
  ],
  RegExp(r'\b(hi|hey|hello|morning)\b'): [
    'Hey! What is on your mind?',
    'Hi, good timing. I just got out of a meeting.',
  ],
  RegExp(r'\b(ship|release|deploy|launch|staging)\b'): [
    'Staging looks healthy from here. I am good to go.',
    'Let us ship it after the checklist is green.',
    'I will keep an eye on the dashboards once it is out.',
  ],
  RegExp(r'\b(bug|issue|crash|broken|fix)\b'): [
    'Can you send the steps to reproduce?',
    'Looking now. It might be related to the last migration.',
  ],
  RegExp(r'\b(meet|meeting|call|sync|review|tomorrow)\b'): [
    'Works for me. I will add it to the calendar.',
    'Can we make it 15 minutes? I have a hard stop.',
  ],
  RegExp(r'\b(design|figma|mock|spec|icon)\b'): [
    'That direction feels right. Send the link when it is ready.',
    'I like it. Can we check how it holds up on small screens?',
  ],
  RegExp(r'\b(lunch|coffee)\b'): [
    'Yes please. Ten minutes?',
    'I am in. Meet you downstairs.',
  ],
  RegExp(r'\?'): [
    'Good question. Let me check and get back to you.',
    'I think so, but Priya would know for sure.',
    'Not yet. It is next on my list.',
  ],
};

const _fallbackReplies = [
  'Sounds good to me.',
  'Got it, thanks for the heads up.',
  'Makes sense. I will take a look this afternoon.',
  'Noted. Let me know if you need anything from me.',
];
