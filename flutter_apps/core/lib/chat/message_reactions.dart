import 'package:flutter/material.dart';

enum _Reaction {
  like('Like', Icons.thumb_up),
  love('Love', Icons.favorite),
  funny('Funny', Icons.sentiment_very_satisfied),
  celebrate('Celebrate', Icons.celebration),
  fire('Fire', Icons.local_fire_department);

  const _Reaction(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _me = 'You';

class _Message {
  _Message(this.author, this.text, this.reactions);

  final String author;
  final String text;

  /// Who picked each reaction. A person can hold several at once.
  final Map<_Reaction, Set<String>> reactions;

  bool get isMine => author == _me;
}

class MessageReactions extends StatefulWidget {
  const MessageReactions({super.key});

  @override
  State<MessageReactions> createState() => _MessageReactionsState();
}

class _MessageReactionsState extends State<MessageReactions> {
  final _messages = [
    _Message('Lena', 'The new onboarding numbers are in.', {}),
    _Message('Lena', 'Activation is up 18% week over week.', {
      _Reaction.celebrate: {'Omar', 'Jin'},
      _Reaction.fire: {'Omar'},
    }),
    _Message(_me, 'That is the best week since launch.', {
      _Reaction.like: {'Lena'},
    }),
    _Message('Omar', 'Drinks on Friday then?', {
      _Reaction.funny: {'Jin', 'Lena', _me},
    }),
  ];

  _Message? _pickerFor;

  void _toggle(_Message message, _Reaction reaction) {
    setState(() {
      final people = message.reactions.putIfAbsent(reaction, () => {});
      if (!people.remove(_me)) people.add(_me);
      if (people.isEmpty) message.reactions.remove(reaction);
      _pickerFor = null;
    });
  }

  void _showWhoReacted(_Message message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final entry in message.reactions.entries)
              for (final person in entry.value)
                ListTile(
                  leading: CircleAvatar(child: Text(person[0])),
                  title: Text(person),
                  trailing: Icon(
                    entry.key.icon,
                    semanticLabel: entry.key.label,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Growth team')),
      body: GestureDetector(
        // Tapping away closes the picker, as it does in most chat apps.
        behavior: HitTestBehavior.translucent,
        onTap: () => setState(() => _pickerFor = null),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Long-press or right-click a message to react.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            for (final message in _messages)
              _MessageRow(
                message: message,
                pickerOpen: identical(_pickerFor, message),
                onOpenPicker: () => setState(() => _pickerFor = message),
                onToggle: (reaction) => _toggle(message, reaction),
                onShowPeople: () => _showWhoReacted(message),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.pickerOpen,
    required this.onOpenPicker,
    required this.onToggle,
    required this.onShowPeople,
  });

  final _Message message;
  final bool pickerOpen;
  final VoidCallback onOpenPicker;
  final ValueChanged<_Reaction> onToggle;
  final VoidCallback onShowPeople;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = message.isMine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: pickerOpen
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Picker(message: message, onPick: onToggle),
                  )
                : const SizedBox.shrink(),
          ),
          if (!mine)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                message.author,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          GestureDetector(
            onLongPress: onOpenPicker,
            onSecondaryTap: onOpenPicker,
            onDoubleTap: () => onToggle(_Reaction.love),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: mine ? scheme.primary : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mine ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
          ),
          if (message.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: mine ? WrapAlignment.end : WrapAlignment.start,
                children: [
                  for (final entry in message.reactions.entries)
                    _Pill(
                      reaction: entry.key,
                      count: entry.value.length,
                      reactedByMe: entry.value.contains(_me),
                      onTap: () => onToggle(entry.key),
                      onLongPress: onShowPeople,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({required this.message, required this.onPick});

  final _Message message;
  final ValueChanged<_Reaction> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 3,
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(28),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, reaction) in _Reaction.values.indexed)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: Duration(milliseconds: 160 + index * 40),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: IconButton(
                tooltip: reaction.label,
                isSelected:
                    message.reactions[reaction]?.contains(_me) ?? false,
                color: scheme.onSurfaceVariant,
                selectedIcon: Icon(reaction.icon, color: scheme.primary),
                onPressed: () => onPick(reaction),
                icon: Icon(reaction.icon),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.reaction,
    required this.count,
    required this.reactedByMe,
    required this.onTap,
    required this.onLongPress,
  });

  final _Reaction reaction;
  final int count;
  final bool reactedByMe;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground =
        reactedByMe ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Material(
      color: reactedByMe
          ? scheme.primaryContainer
          : scheme.surfaceContainerHigh,
      shape: StadiumBorder(
        side: BorderSide(
          color: reactedByMe ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                reaction.icon,
                size: 14,
                color: foreground,
                semanticLabel: reaction.label,
              ),
              const SizedBox(width: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Text(
                  '$count',
                  key: ValueKey(count),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
