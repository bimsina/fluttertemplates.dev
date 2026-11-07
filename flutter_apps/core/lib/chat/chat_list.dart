import 'package:flutter/material.dart';

enum _Filter { all, unread, groups }

class _Chat {
  _Chat({
    required this.name,
    required this.preview,
    required this.time,
    this.unread = 0,
    this.isGroup = false,
    this.pinned = false,
    this.muted = false,
    this.sentByMe = false,
    this.online = false,
  });

  final String name;
  final String preview;
  final String time;
  int unread;
  final bool isGroup;
  bool pinned;
  bool muted;
  final bool sentByMe;
  final bool online;

  String get initials => name
      .split(' ')
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _chats = [
    _Chat(
      name: 'Design crit',
      preview: 'Nadia: Uploaded the second round',
      time: '09:42',
      unread: 12,
      isGroup: true,
      pinned: true,
    ),
    _Chat(
      name: 'Tomas Silva',
      preview: 'Sounds good, see you at 3',
      time: '09:15',
      sentByMe: true,
      pinned: true,
      online: true,
    ),
    _Chat(
      name: 'Aisha Khan',
      preview: 'Could you review my PR when you have a minute?',
      time: '08:50',
      unread: 2,
      online: true,
    ),
    _Chat(
      name: 'Platform on-call',
      preview: 'Ravi: Alert cleared, closing the incident',
      time: 'Tue',
      unread: 48,
      isGroup: true,
      muted: true,
    ),
    _Chat(
      name: 'Hana Sato',
      preview: 'Thanks for the intro!',
      time: 'Tue',
    ),
    _Chat(
      name: 'Weekend hikers',
      preview: 'You: I can drive this time',
      time: 'Mon',
      isGroup: true,
      sentByMe: true,
    ),
    _Chat(
      name: 'Leo Martin',
      preview: 'Invoice attached',
      time: 'Sun',
      unread: 1,
    ),
    _Chat(
      name: 'Grace Okafor',
      preview: 'Happy to jump on a call next week',
      time: 'Sat',
    ),
  ];

  var _query = '';
  var _filter = _Filter.all;

  /// Muted chats keep their badge but stay out of the total, as in most apps.
  int get _unreadChats =>
      _chats.where((c) => c.unread > 0 && !c.muted).length;

  List<_Chat> get _visible {
    final query = _query.trim().toLowerCase();
    final matches = _chats.where((chat) {
      final passesFilter = switch (_filter) {
        _Filter.all => true,
        _Filter.unread => chat.unread > 0,
        _Filter.groups => chat.isGroup,
      };
      return passesFilter &&
          (chat.name.toLowerCase().contains(query) ||
              chat.preview.toLowerCase().contains(query));
    }).toList();
    // `sort` is not stable, so break ties with the original inbox order.
    matches.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return _chats.indexOf(a).compareTo(_chats.indexOf(b));
    });
    return matches;
  }

  void _open(_Chat chat) {
    setState(() => chat.unread = 0);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _ThreadPage(chat: chat)),
    );
  }

  void _showActions(_Chat chat) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) {
        void act(VoidCallback change) {
          Navigator.of(sheet).pop();
          setState(change);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  chat.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(chat.pinned ? 'Unpin' : 'Pin to top'),
                onTap: () => act(() => chat.pinned = !chat.pinned),
              ),
              ListTile(
                leading: Icon(
                  chat.muted
                      ? Icons.notifications_outlined
                      : Icons.notifications_off_outlined,
                ),
                title: Text(chat.muted ? 'Unmute' : 'Mute'),
                onTap: () => act(() => chat.muted = !chat.muted),
              ),
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined),
                title: Text(chat.unread > 0 ? 'Mark as read' : 'Mark as unread'),
                onTap: () => act(() => chat.unread = chat.unread > 0 ? 0 : 1),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete chat'),
                onTap: () => act(() => _chats.remove(chat)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: Text(_unreadChats == 0 ? 'Chats' : 'Chats ($_unreadChats)'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New chat',
        onPressed: () => _showDemo(context, 'New chat (demo)'),
        child: const Icon(Icons.edit_outlined),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBar(
              elevation: const WidgetStatePropertyAll(0),
              hintText: 'Search chats',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final (filter, label) in const [
                  (_Filter.all, 'All'),
                  (_Filter.unread, 'Unread'),
                  (_Filter.groups, 'Groups'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      showCheckmark: false,
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      'No chats match',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: visible.length,
                    itemBuilder: (context, index) => _ChatRow(
                      key: ObjectKey(visible[index]),
                      chat: visible[index],
                      onTap: () => _open(visible[index]),
                      onActions: () => _showActions(visible[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onActions,
  });

  final _Chat chat;
  final VoidCallback onTap;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasUnread = chat.unread > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onActions,
      onSecondaryTap: onActions,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _Avatar(chat: chat),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                chat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (chat.muted) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 14,
                                color: scheme.onSurfaceVariant,
                                semanticLabel: 'Muted',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chat.time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: hasUnread && !chat.muted
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (chat.sentByMe) ...[
                        Icon(
                          Icons.done_all,
                          size: 15,
                          color: scheme.primary,
                          semanticLabel: 'Read',
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: hasUnread
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (chat.pinned) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                          semanticLabel: 'Pinned',
                        ),
                      ],
                      if (hasUnread) ...[
                        const SizedBox(width: 6),
                        Badge(
                          label: Text(chat.unread > 9 ? '9+' : '${chat.unread}'),
                          backgroundColor: chat.muted
                              ? scheme.outline
                              : scheme.primary,
                          textColor: chat.muted
                              ? scheme.surface
                              : scheme.onPrimary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.chat});

  final _Chat chat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: chat.isGroup
              ? scheme.tertiaryContainer
              : scheme.secondaryContainer,
          foregroundColor: chat.isGroup
              ? scheme.onTertiaryContainer
              : scheme.onSecondaryContainer,
          child: chat.isGroup
              ? const Icon(Icons.groups_outlined)
              : Text(chat.initials),
        ),
        if (chat.online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThreadPage extends StatelessWidget {
  const _ThreadPage({required this.chat});

  final _Chat chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chat.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(chat.preview, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
