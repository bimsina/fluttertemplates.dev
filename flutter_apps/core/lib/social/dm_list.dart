import 'package:flutter/material.dart';

const _conversations = [
  {'user': 'Alice', 'last': 'Hey, how are you?', 'unread': true},
  {'user': 'Bob', 'last': 'See you tomorrow', 'unread': false},
];

class DmList extends StatelessWidget {
  const DmList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, i) {
          final c = _conversations[i];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(child: Text((c['user'] as String)[0])),
                if (c['unread'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('1', style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              c['user'] as String,
              style: TextStyle(
                fontWeight: c['unread'] == true
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            subtitle: Text(c['last'] as String),
            trailing: const Text('2m', style: TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }
}
