import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../state/chat_scope.dart';
import '../state/chat_store.dart';
import '../widgets/avatars.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_style.dart';
import '../widgets/person_tile.dart';
import '../widgets/section_label.dart';

/// Group info, and the equivalent details page for a direct thread.
class ConversationInfoScreen extends StatelessWidget {
  const ConversationInfoScreen({super.key, required this.conversationId});

  final String conversationId;

  Future<void> _rename(BuildContext context, Conversation conversation) async {
    final store = ChatScope.read(context);
    final title = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (_) => _RenameDialog(initialTitle: store.titleOf(conversation)),
    );
    if (title != null && title.isNotEmpty) {
      store.runAction(
        () => store.repository.renameGroup(conversation.id, title),
        failure: 'Could not rename the group.',
      );
    }
  }

  Future<void> _addPeople(
    BuildContext context,
    Conversation conversation,
  ) async {
    final store = ChatScope.read(context);
    final candidates = store.teammates
        .where((person) => !conversation.memberIds.contains(person.id))
        .toList();
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _AddPeopleSheet(candidates: candidates),
    );
    if (picked != null && picked.isNotEmpty) {
      store.runAction(
        () => store.repository.addMembers(conversation.id, picked),
        failure: 'Could not add people.',
      );
    }
  }

  Future<void> _confirmLeave(
    BuildContext context,
    Conversation conversation,
  ) async {
    final store = ChatScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = store.titleOf(conversation);
    final isGroup = conversation.isGroup;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isGroup ? 'Leave $title?' : 'Delete this conversation?'),
          content: Text(
            isGroup
                ? 'You will stop getting messages from this group.'
                : 'The message history with $title will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(isGroup ? 'Leave' : 'Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    // The store reports a failure itself, as a snack bar.
    if (!await store.leave(conversation.id)) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isGroup ? 'You left $title' : 'Conversation with $title deleted',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final conversation = store.conversation(conversationId);
    if (conversation == null) return const Scaffold();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final members = store.membersOf(conversation)
      ..sort((a, b) {
        if (a.id == store.me.id) return -1;
        if (b.id == store.me.id) return 1;
        return a.name.compareTo(b.name);
      });
    final canAddPeople =
        conversation.isGroup &&
        store.teammates.any((p) => !conversation.memberIds.contains(p.id));

    return Scaffold(
      body: Column(
        children: [
          ChatHeader(
            leading: IconButton(
              tooltip: 'Back',
              onPressed: store.navigation.closeInfo,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            trailing: conversation.isGroup
                ? IconButton(
                    tooltip: 'Rename group',
                    onPressed: () => _rename(context, conversation),
                    icon: const Icon(Icons.edit_outlined),
                  )
                : null,
            child: Text(
              conversation.isGroup ? 'Group info' : 'Details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Summary(store: store, conversation: conversation),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToggleCard(
                          icon: conversation.isMuted
                              ? Icons.notifications_off_rounded
                              : Icons.notifications_none_rounded,
                          label: conversation.isMuted ? 'Muted' : 'Mute',
                          isActive: conversation.isMuted,
                          onTap: () => store.runAction(
                            () => store.repository.setMuted(
                              conversation.id,
                              muted: !conversation.isMuted,
                            ),
                            failure: 'Could not update the conversation.',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ToggleCard(
                          icon: conversation.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          label: conversation.isPinned ? 'Pinned' : 'Pin',
                          isActive: conversation.isPinned,
                          onTap: () => store.runAction(
                            () => store.repository.setPinned(
                              conversation.id,
                              pinned: !conversation.isPinned,
                            ),
                            failure: 'Could not update the conversation.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (conversation.isGroup) ...[
                  const SizedBox(height: 8),
                  SectionLabel(
                    '${members.length} members',
                    trailing: canAddPeople
                        ? TextButton.icon(
                            onPressed: () => _addPeople(context, conversation),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 18,
                            ),
                            label: const Text('Add'),
                          )
                        : null,
                  ),
                  for (final member in members)
                    PersonTile(
                      user: member,
                      subtitle: member.id == store.me.id ? 'You' : member.role,
                      onTap: member.id == store.me.id
                          ? null
                          : () => store.openDirectThread(member.id),
                    ),
                ],
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLeave(context, conversation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    icon: Icon(
                      conversation.isGroup
                          ? Icons.logout_rounded
                          : Icons.delete_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      conversation.isGroup
                          ? 'Leave group'
                          : 'Delete conversation',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.store, required this.conversation});

  final ChatStore store;
  final Conversation conversation;

  String? get _subtitle {
    if (conversation.isGroup) return conversation.topic;
    final partner = store.partnerOf(conversation);
    final presence = switch (partner.presence) {
      Presence.online => 'Online',
      Presence.away => 'Away',
      Presence.offline => 'Offline',
    };
    return '${partner.role}  ·  $presence';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          ConversationAvatar(conversation: conversation, size: 84),
          const SizedBox(height: 14),
          Text(
            store.titleOf(conversation),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = isActive ? scheme.onPrimaryContainer : scheme.onSurface;
    return Semantics(
      button: true,
      toggled: isActive,
      child: Material(
        color: isActive ? scheme.primaryContainer : scheme.raised,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialTitle,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename group'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _AddPeopleSheet extends StatefulWidget {
  const _AddPeopleSheet({required this.candidates});

  final List<ChatUser> candidates;

  @override
  State<_AddPeopleSheet> createState() => _AddPeopleSheetState();
}

class _AddPeopleSheetState extends State<_AddPeopleSheet> {
  final _picked = <String>{};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final person in widget.candidates)
                  PersonTile(
                    user: person,
                    isChecked: _picked.contains(person.id),
                    onTap: () => setState(() {
                      if (!_picked.remove(person.id)) _picked.add(person.id);
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _picked.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_picked.toList()),
                child: Text(
                  _picked.isEmpty
                      ? 'Pick people to add'
                      : 'Add ${_picked.length}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
