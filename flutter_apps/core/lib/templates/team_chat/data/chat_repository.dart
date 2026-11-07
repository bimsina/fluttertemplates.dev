import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// Thrown by [ChatRepository.sendMessage] when the backend definitely did not
/// keep the message, for example because it failed validation.
class MessageRejectedException implements Exception {
  const MessageRejectedException(this.message);

  final String message;

  @override
  String toString() => 'MessageRejectedException: $message';
}

/// Everything the app needs from a backend.
///
/// The UI only talks to this interface, so connecting a real service means
/// writing one class that implements it and returning that from
/// `createDefaultRepository()` in `default_repository.dart`.
/// Each `watch` stream emits the current value on listen and again on every
/// change, which maps directly onto a websocket or a realtime database query.
abstract class ChatRepository {
  /// The signed-in user.
  ChatUser get currentUser;

  /// Everyone in the workspace, including [currentUser].
  Stream<List<ChatUser>> watchUsers();

  /// Conversations the current user belongs to, in no particular order.
  Stream<List<Conversation>> watchConversations();

  /// Messages of one conversation, oldest first.
  Stream<List<Message>> watchMessages(String conversationId);

  /// Ids of the people typing, by conversation id.
  Stream<Map<String, Set<String>>> watchTyping();

  /// Sends a message.
  ///
  /// Throw [MessageRejectedException] only when you know the message was not
  /// kept. Any other error, such as a timeout, is treated as an unknown
  /// outcome: the message may be on the server, so the UI says so and warns
  /// before an edit that could post it twice.
  ///
  /// [clientMessageId] is generated on the device and stays the same when a
  /// failed send is retried. Treat it as an idempotency key, because a retry
  /// can follow a send that worked but lost its response: a second call with
  /// the same id must return the first message and not post a new one. Using
  /// it as the message's id also keeps the row stable when the stream catches
  /// up.
  Future<Message> sendMessage({
    required String conversationId,
    required String text,
    String? replyToId,
    String? clientMessageId,
  });

  /// Adds the current user's reaction, or removes it if already there.
  Future<void> toggleReaction({
    required String conversationId,
    required String messageId,
    required ReactionKind kind,
  });

  /// Must not throw for an id the backend doesn't have: a message with an
  /// unknown send outcome is deleted here too, in case it did arrive.
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  });

  Future<void> markRead(String conversationId);

  /// Creates a direct thread for one person and a group for several. A direct
  /// thread that already exists is returned instead of being duplicated.
  Future<Conversation> createConversation({
    required List<String> memberIds,
    String? title,
  });

  Future<void> renameGroup(String conversationId, String title);

  Future<void> addMembers(String conversationId, List<String> memberIds);

  Future<void> setMuted(String conversationId, {required bool muted});

  Future<void> setPinned(String conversationId, {required bool pinned});

  /// Throw if the user wasn't removed. Their draft and unsent messages for
  /// this conversation are kept until this completes.
  Future<void> leaveConversation(String conversationId);

  /// Messages containing [query], newest first.
  Future<List<Message>> searchMessages(String query);

  void dispose();
}
