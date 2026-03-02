import 'package:flutter/material.dart';

const _results = [
  {'title': 'Flutter Documentation', 'snippet': 'Official Flutter docs...'},
  {'title': 'Flutter Packages', 'snippet': 'Pub.dev package search...'},
];

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Images'), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Videos'), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Relevance',
                  items: ['Relevance', 'Date'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  title: Text(r['title'] as String),
                  subtitle: Text(r['snippet'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
