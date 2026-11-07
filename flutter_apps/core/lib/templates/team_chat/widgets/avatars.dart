import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../state/chat_scope.dart';
import 'chat_style.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.size = 48,
    this.showPresence = false,
  });

  final ChatUser user;
  final double size;
  final bool showPresence;

  @override
  Widget build(BuildContext context) {
    final tile = _InitialsTile(
      id: user.id,
      initials: user.initials,
      size: size,
    );
    if (!showPresence || user.presence == Presence.offline) return tile;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          tile,
          Positioned(
            right: -2,
            bottom: -2,
            child: _PresenceDot(presence: user.presence, size: size * 0.32),
          ),
        ],
      ),
    );
  }
}

class _PresenceDot extends StatelessWidget {
  const _PresenceDot({required this.presence, required this.size});

  final Presence presence;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOnline = presence == Presence.online;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? scheme.primary : scheme.surface,
          border: isOnline
              ? null
              : Border.all(color: scheme.outline, width: size * 0.16),
        ),
      ),
    );
  }
}

class _InitialsTile extends StatelessWidget {
  const _InitialsTile({
    required this.id,
    required this.initials,
    required this.size,
  });

  final String id;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tone = PersonTone.of(id, Theme.of(context).colorScheme);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: tone.background,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.62),
        ),
      ),
      child: ExcludeSemantics(
        child: Text(
          initials,
          maxLines: 1,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: tone.foreground,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// One tile split into a mosaic of up to four members, so a group reads as a
/// team at a glance and never looks like a person.
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({super.key, required this.members, this.size = 48});

  final List<ChatUser> members;
  final double size;

  Widget _cell(ChatUser user, ColorScheme scheme) {
    final tone = PersonTone.of(user.id, scheme);
    return Expanded(
      child: ColoredBox(
        color: tone.background,
        child: Center(
          child: Text(
            user.initials.characters.first,
            maxLines: 1,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: tone.foreground,
              fontSize: size * 0.27,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stack(List<Widget> cells, double gap) {
    return Expanded(
      child: Column(
        spacing: gap,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gap = size * 0.035;
    final cells = [for (final user in members.take(4)) _cell(user, scheme)];
    final split = (cells.length / 2).floor();

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(size * 0.62),
            ),
          ),
          child: Row(
            spacing: gap,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (split > 0) _stack(cells.sublist(0, split), gap),
              _stack(cells.sublist(split), gap),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.conversation,
    this.size = 48,
    this.showPresence = true,
  });

  final Conversation conversation;
  final double size;
  final bool showPresence;

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    if (conversation.isGroup) {
      final others = store
          .membersOf(conversation)
          .where((user) => user.id != store.me.id)
          .toList();
      return GroupAvatar(members: others, size: size);
    }
    return UserAvatar(
      user: store.partnerOf(conversation),
      size: size,
      showPresence: showPresence,
    );
  }
}
