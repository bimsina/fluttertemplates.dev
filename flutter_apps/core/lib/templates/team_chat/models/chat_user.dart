import 'package:flutter/widgets.dart';

enum Presence { online, away, offline }

class ChatUser {
  const ChatUser({
    required this.id,
    required this.name,
    required this.role,
    this.presence = Presence.offline,
  });

  final String id;
  final String name;
  final String role;
  final Presence presence;

  String get firstName => name.split(' ').first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final picked = parts.length == 1 ? parts : [parts.first, parts.last];
    return picked.map((part) => part.characters.first).join().toUpperCase();
  }

  ChatUser copyWith({Presence? presence}) {
    return ChatUser(
      id: id,
      name: name,
      role: role,
      presence: presence ?? this.presence,
    );
  }
}
