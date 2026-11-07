import 'package:flutter/material.dart';

const _notifications = [
  {'title': 'New message', 'body': 'Sarah replied to your comment', 'time': '2m ago', 'read': false},
  {'title': 'Order shipped', 'body': 'Your order #1234 is on the way', 'time': '1h ago', 'read': true},
  {'title': 'Reminder', 'body': 'Team meeting starts in 30 min', 'time': '3h ago', 'read': true},
];

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final _read = {
    for (final n in _notifications)
      if (n['read'] as bool) n['title'] as String,
  };

  @override
  Widget build(BuildContext context) {
    final titles = _notifications.map((n) => n['title'] as String);
    final hasUnread = !_read.containsAll(titles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: hasUnread
                ? () => setState(() => _read.addAll(titles))
                : null,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, i) {
          final n = _notifications[i];
          final title = n['title'] as String;
          final unread = !_read.contains(title);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: unread ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: unread ? Colors.blue.withValues(alpha: 0.2) : Colors.grey[300],
                child: Icon(Icons.notifications, color: unread ? Colors.blue[700] : Colors.grey[600]),
              ),
              title: Text(title),
              subtitle: Text(n['body'] as String),
              trailing: Text(n['time'] as String, style: Theme.of(context).textTheme.bodySmall),
              onTap: () {
                setState(() => _read.add(title));
                _showDemo(context, 'Open $title (demo)');
              },
            ),
          );
        },
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
