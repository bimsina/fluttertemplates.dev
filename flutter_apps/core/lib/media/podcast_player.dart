import 'package:flutter/material.dart';

const _episodes = [
  {'title': 'Episode 1: Intro', 'duration': '45:12', 'date': 'Mar 1'},
  {'title': 'Episode 2: Basics', 'duration': '52:30', 'date': 'Feb 28'},
  {'title': 'Episode 3: Advanced', 'duration': '1:05:00', 'date': 'Feb 25'},
];

class PodcastPlayer extends StatelessWidget {
  const PodcastPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast')),
      body: ListView(
        children: [
          Container(
            height: 220,
            color: Colors.amber.withValues(alpha: 0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.podcasts, size: 80, color: Colors.amber[700]),
                const SizedBox(height: 12),
                Text(
                  'Tech Talk Podcast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Host: Jane Doe', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
            title: const Text('Now Playing'),
            subtitle: Text(_episodes[0]['title'] as String),
          ),
          const Divider(),
          ..._episodes.map((e) => ListTile(
                leading: const Icon(Icons.podcasts),
                title: Text(e['title'] as String),
                subtitle: Text('${e['duration']} • ${e['date']}'),
                trailing: const Icon(Icons.download),
                onTap: () {},
              )),
        ],
      ),
    );
  }
}
