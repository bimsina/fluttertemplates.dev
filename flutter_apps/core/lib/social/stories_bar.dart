import 'package:flutter/material.dart';

const _users = ['You', 'Alice', 'Bob', 'Charlie', 'Diana'];

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: _users.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.primaries[i].withValues(alpha: 0.5),
                        child: i == 0
                            ? const Icon(Icons.add)
                            : Text(_users[i][0]),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 72,
                        child: Text(
                          _users[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[i % 5].withValues(alpha: 0.5),
                ),
                title: Text('Feed item ${i + 1}'),
                subtitle: const Text('Posted 2h ago'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
