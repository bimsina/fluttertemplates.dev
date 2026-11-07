import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../state/chat_scope.dart';
import '../state/chat_store.dart';
import '../widgets/avatars.dart';
import '../widgets/chat_style.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/formatting.dart';
import '../widgets/person_tile.dart';
import '../widgets/section_label.dart';
import '../widgets/sync_banner.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late final TextEditingController _search = TextEditingController(
    text: ChatScope.read(context).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    ChatScope.read(context).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(unread: store.unreadConversations),
            _SearchField(
              controller: _search,
              onChanged: store.setQuery,
              onClear: _clearSearch,
            ),
            if (store.isReady && store.hasSyncError)
              SyncBanner(onRetry: store.reconnect),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: switch ((store.isReady, store.isSearching)) {
                  (false, _) when store.hasSyncError => EmptyState(
                    key: const ValueKey('error'),
                    icon: Icons.cloud_off_rounded,
                    title: 'Could not load conversations',
                    message: 'Check your connection and try again.',
                    action: FilledButton(
                      onPressed: store.reconnect,
                      child: const Text('Try again'),
                    ),
                  ),
                  (false, _) => const _LoadingList(),
                  (_, true) => const _SearchResults(key: ValueKey('search')),
                  _ => const _ConversationList(key: ValueKey('list')),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unread == 0
                      ? 'Northlight team'
                      : 'Northlight team  ·  $unread unread',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Messages',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'New conversation',
            onPressed: ChatScope.read(context).navigation.openComposer,
            style: IconButton.styleFrom(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search chats and people',
          hintMaxLines: 1,
          isDense: true,
          filled: true,
          fillColor: scheme.raised,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                iconSize: 18,
                icon: const Icon(Icons.close_rounded),
              );
            },
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final online = store.onlineTeammates;
    final conversations = store.filteredConversations;
    final pinned = conversations.where((c) => c.isPinned).toList();
    final recent = conversations.where((c) => !c.isPinned).toList();

    void open(Conversation conversation) {
      store.openConversation(conversation.id);
    }

    Widget tile(Conversation conversation) {
      return ConversationTile(
        key: ValueKey(conversation.id),
        conversation: conversation,
        isSelected: conversation.id == store.navigation.selectedId,
        onTap: () => open(conversation),
      );
    }

    return CustomScrollView(
      slivers: [
        if (online.isNotEmpty)
          SliverToBoxAdapter(child: _ActiveNowStrip(people: online)),
        SliverToBoxAdapter(child: _FilterBar(store: store)),
        if (conversations.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyList(store: store),
          )
        else ...[
          if (pinned.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionLabel('Pinned')),
            SliverList.list(children: [for (final c in pinned) tile(c)]),
          ],
          if (recent.isNotEmpty) ...[
            if (pinned.isNotEmpty)
              const SliverToBoxAdapter(child: SectionLabel('Recent')),
            SliverList.list(children: [for (final c in recent) tile(c)]),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ],
    );
  }
}

class _ActiveNowStrip extends StatelessWidget {
  const _ActiveNowStrip({required this.people});

  final List<ChatUser> people;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = ChatScope.read(context);
    return SizedBox(
      height: 72 + MediaQuery.textScalerOf(context).scale(16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        itemCount: people.length,
        separatorBuilder: (_, _) => const SizedBox(width: 2),
        itemBuilder: (context, index) {
          final person = people[index];
          return InkWell(
            onTap: () => store.openDirectThread(person.id),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 62,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  UserAvatar(user: person, size: 44, showPresence: true),
                  const SizedBox(height: 5),
                  Text(
                    person.firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.store});

  final ChatStore store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          for (final (filter, label) in const [
            (ConversationFilter.all, 'All'),
            (ConversationFilter.unread, 'Unread'),
            (ConversationFilter.groups, 'Groups'),
          ]) ...[
            _FilterPill(
              label: label,
              isSelected: store.filter == filter,
              onTap: () => store.setFilter(filter),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? scheme.onSurface : scheme.raised,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? scheme.surface : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.store});

  final ChatStore store;

  @override
  Widget build(BuildContext context) {
    return switch (store.filter) {
      ConversationFilter.unread => const EmptyState(
        icon: Icons.mark_chat_read_rounded,
        title: 'All caught up',
        message: 'New messages will show up here.',
      ),
      ConversationFilter.groups => EmptyState(
        icon: Icons.groups_rounded,
        title: 'No groups yet',
        message: 'Bring a few teammates into one thread.',
        action: FilledButton.tonal(
          onPressed: store.navigation.openComposer,
          child: const Text('Create a group'),
        ),
      ),
      ConversationFilter.all => EmptyState(
        icon: Icons.forum_rounded,
        title: 'No conversations yet',
        message: 'Start one with anyone on your team.',
        action: FilledButton.tonal(
          onPressed: store.navigation.openComposer,
          child: const Text('New conversation'),
        ),
      ),
    };
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final conversations = store.conversationHits;
    final people = store.peopleHits;
    final hits = store.messageHits;

    if (conversations.isEmpty && people.isEmpty && hits.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results',
        message: 'Nothing matches "${store.query.trim()}".',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (conversations.isNotEmpty) ...[
          const SectionLabel('Conversations'),
          for (final conversation in conversations)
            ConversationTile(
              conversation: conversation,
              isSelected: conversation.id == store.navigation.selectedId,
              onTap: () => store.openConversation(conversation.id),
            ),
        ],
        if (people.isNotEmpty) ...[
          const SectionLabel('People'),
          for (final person in people)
            PersonTile(
              user: person,
              onTap: () => store.openDirectThread(person.id),
            ),
        ],
        if (hits.isNotEmpty) ...[
          const SectionLabel('Messages'),
          for (final hit in hits) _MessageHitTile(message: hit),
        ],
      ],
    );
  }
}

class _MessageHitTile extends StatelessWidget {
  const _MessageHitTile({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final conversation = store.conversation(message.conversationId);
    if (conversation == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () =>
          store.openConversation(conversation.id, focusMessageId: message.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(user: store.user(message.senderId), size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.titleOf(conversation),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatListTime(message.sentAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _HighlightedText(
                    text: message.text,
                    term: store.query.trim(),
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

/// Shows [text] with the first match of [term] emphasized.
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.term});

  final String text;
  final String term;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.35,
    );
    final start = text.toLowerCase().indexOf(term.toLowerCase());
    if (term.isEmpty || start == -1) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    final end = start + term.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Placeholder rows shown until the first conversation list arrives.
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.raised;

    Widget block(double? width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      itemCount: 6,
      itemBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              block(48, 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    block(120, 12),
                    const SizedBox(height: 8),
                    block(null, 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
