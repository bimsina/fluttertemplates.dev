import 'package:flutter/material.dart';

const _emails = [
  {'from': 'Sarah', 'subject': 'Project update', 'preview': 'Here is the latest...', 'time': '2:30 PM', 'unread': true},
  {'from': 'Team', 'subject': 'Meeting notes', 'preview': 'Summary of our discussion...', 'time': '11:00 AM', 'unread': true},
  {'from': 'Newsletter', 'subject': 'Weekly digest', 'preview': 'Top stories this week...', 'time': 'Yesterday', 'unread': false},
];

class EmailInbox extends StatelessWidget {
  const EmailInbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _emails.length,
        itemBuilder: (context, i) {
          final e = _emails[i];
          final unread = e['unread'] as bool;
          return ListTile(
            leading: CircleAvatar(
              child: Text((e['from'] as String)[0].toUpperCase()),
            ),
            title: Text(
              e['subject'] as String,
              style: TextStyle(
                fontWeight: unread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${e['from']} — ${e['preview']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(e['time'] as String, style: Theme.of(context).textTheme.bodySmall),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
    );
  }
}
