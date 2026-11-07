import 'package:flutter/material.dart';

const _notifications = [
  {'user': 'Alice', 'type': 'follow', 'unread': true},
  {'user': 'Bob', 'type': 'like', 'unread': true},
  {'user': 'Charlie', 'type': 'comment', 'unread': false},
];

String _message(Map<String, Object> n) {
  final user = n['user'];
  return switch (n['type']) {
    'follow' => '$user followed you',
    'like' => '$user liked your post',
    'comment' => '$user commented on your post',
    _ => '$user sent you a notification',
  };
}

class NotificationsFeed extends StatelessWidget {
  const NotificationsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, i) {
          final n = _notifications[i];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(child: Text((n['user'] as String)[0])),
                if (n['unread'] == true)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(_message(n)),
            subtitle: Text('2h ago'),
          );
        },
      ),
    );
  }
}
