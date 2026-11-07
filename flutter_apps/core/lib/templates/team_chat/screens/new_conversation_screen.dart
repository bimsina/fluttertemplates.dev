import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../state/chat_scope.dart';
import '../widgets/avatars.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_style.dart';
import '../widgets/empty_state.dart';
import '../widgets/person_tile.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final _search = TextEditingController();
  final _groupName = TextEditingController();
  final _selectedIds = <String>[];
  String _query = '';

  bool get _isGroup => _selectedIds.length > 1;

  @override
  void dispose() {
    _search.dispose();
    _groupName.dispose();
    super.dispose();
  }

  void _toggle(ChatUser user) {
    setState(() {
      if (!_selectedIds.remove(user.id)) _selectedIds.add(user.id);
    });
  }

  void _start() {
    final store = ChatScope.read(context);
    if (_isGroup) {
      store.createGroup(List.of(_selectedIds), _groupName.text.trim());
    } else {
      store.openDirectThread(_selectedIds.single);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ChatScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final needle = _query.trim().toLowerCase();
    final people = store.teammates
        .where(
          (person) =>
              person.name.toLowerCase().contains(needle) ||
              person.role.toLowerCase().contains(needle),
        )
        .toList();

    final fieldDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: scheme.raised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          ChatHeader(
            leading: IconButton(
              tooltip: 'Close',
              onPressed: store.navigation.closeComposer,
              icon: const Icon(Icons.close_rounded),
            ),
            child: Text(
              'New conversation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: fieldDecoration.copyWith(
                hintText: 'Search by name or role',
                hintMaxLines: 1,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                if (_selectedIds.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        for (final id in _selectedIds)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _SelectedChip(
                              user: store.user(id),
                              onRemove: () => _toggle(store.user(id)),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_isGroup)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: TextField(
                      controller: _groupName,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: fieldDecoration.copyWith(
                        hintText: 'Group name (optional)',
                        hintMaxLines: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: people.isEmpty
                ? EmptyState(
                    icon: Icons.person_search_rounded,
                    title: 'Nobody found',
                    message: 'No teammate matches "${_query.trim()}".',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    itemCount: people.length,
                    itemBuilder: (context, index) {
                      final person = people[index];
                      return PersonTile(
                        user: person,
                        isChecked: _selectedIds.contains(person.id),
                        onTap: () => _toggle(person),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedIds.isEmpty ? null : _start,
                  child: Text(switch (_selectedIds.length) {
                    0 => 'Pick at least one person',
                    1 => 'Start chat',
                    final count => 'Create group of ${count + 1}',
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.user, required this.onRemove});

  final ChatUser user;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Material(
        color: scheme.secondaryContainer,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onRemove,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 4, 8, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(user: user, size: 24),
                const SizedBox(width: 6),
                Text(
                  user.firstName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.close_rounded,
                  size: 15,
                  semanticLabel: 'Remove ${user.firstName}',
                  color: scheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
