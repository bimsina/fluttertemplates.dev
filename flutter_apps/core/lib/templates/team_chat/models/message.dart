/// [failed] and [unconfirmed] only appear on messages `ChatStore` holds locally.
/// A repository reports them by throwing from `sendMessage`.
enum MessageStatus {
  sending,
  sent,
  read,

  /// The repository refused the send, so it doesn't have this message.
  failed,

  /// The send ended without an answer, so the repository may have this message.
  unconfirmed;

  /// True once a send has ended without a confirmation.
  bool get needsAttention => this == failed || this == unconfirmed;
}

/// Reactions are a fixed set of named kinds rather than free-form emoji. They
/// render as Material icons, so they need no emoji font and follow the theme.
enum ReactionKind { like, love, celebrate, ship, looking, done }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.replyToId,
    this.status = MessageStatus.sent,
    this.reactions = const {},
    this.isSystem = false,
    this.isDeleted = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime sentAt;

  /// The id of the message this one quotes, if any.
  final String? replyToId;
  final MessageStatus status;

  /// Who reacted, by kind. Kinds with nobody left are removed from the map.
  final Map<ReactionKind, Set<String>> reactions;

  /// Group events such as "Maya renamed the group". [senderId] is the actor.
  final bool isSystem;
  final bool isDeleted;

  Message copyWith({
    String? text,
    MessageStatus? status,
    Map<ReactionKind, Set<String>>? reactions,
    bool? isDeleted,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      text: text ?? this.text,
      sentAt: sentAt,
      replyToId: replyToId,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      isSystem: isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
