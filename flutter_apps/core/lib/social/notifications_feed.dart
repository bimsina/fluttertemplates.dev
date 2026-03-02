import 'package:flutter/material.dart';

const _notifications = [
  {'user': 'Alice', 'type': 'follow', 'unread': true},
  {'user': 'Bob', 'type': 'like', 'unread': true},
  {'user': 'Charlie', 'type': 'comment', 'unread': false},
];

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
            title: Text('${n['user']} ${n['type']}ed you'),
            subtitle: Text('2h ago'),
          );
        },
      ),
    );
  }
}
