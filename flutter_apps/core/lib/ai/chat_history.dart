import 'package:flutter/material.dart';

class _Convo {
  final String title;
  final String snippet;
  final String time;
  final bool pinned;
  const _Convo(this.title, this.snippet, this.time, {this.pinned = false});
}

class ChatHistory extends StatelessWidget {
  const ChatHistory({super.key});

  static const _convos = [
    _Convo('Flutter architecture', 'Let\'s use a repository pattern with…',
        'Now', pinned: true),
    _Convo('Trip to Kyoto', 'A 5-day itinerary focused on temples…', '2h',
        pinned: true),
    _Convo('SQL query help', 'You can use a window function to…', 'Yesterday'),
    _Convo('Resume review', 'Your summary is strong; tighten the…', 'Mon'),
    _Convo('Dinner recipes', 'Here are three 30-minute meals…', 'Sun'),
    _Convo('Marketing copy', 'Three taglines for the launch…', 'Last week'),
  ];

  @override
  Widget build(BuildContext context) {
    final pinned = _convos.where((c) => c.pinned).toList();
    final recent = _convos.where((c) => !c.pinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
          _sectionHeader(context, 'Pinned'),
          for (final c in pinned) _tile(context, c),
          _sectionHeader(context, 'Recent'),
          for (final c in recent) _tile(context, c),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1)),
    );
  }

  Widget _tile(BuildContext context, _Convo c) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(Icons.chat_bubble_outline,
            size: 18, color: scheme.onPrimaryContainer),
      ),
      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(c.snippet, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(c.time,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          if (c.pinned)
            Icon(Icons.push_pin, size: 14, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
