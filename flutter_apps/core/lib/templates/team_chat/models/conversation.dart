import 'message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.memberIds,
    required this.createdAt,
    this.title,
    this.topic,
    this.isGroup = false,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.lastMessage,
  });

  final String id;

  /// Includes the current user.
  final List<String> memberIds;
  final DateTime createdAt;

  /// Set for groups. Direct threads take their title from the other person.
  final String? title;
  final String? topic;
  final bool isGroup;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final Message? lastMessage;

  DateTime get updatedAt => lastMessage?.sentAt ?? createdAt;

  Conversation copyWith({
    List<String>? memberIds,
    String? title,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    Message? Function()? lastMessage,
  }) {
    return Conversation(
      id: id,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt,
      title: title ?? this.title,
      topic: topic,
      isGroup: isGroup,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      lastMessage: lastMessage == null ? this.lastMessage : lastMessage(),
    );
  }
}
