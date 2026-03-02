import 'package:flutter/material.dart';

const _sections = [
  {'title': 'Settings', 'items': ['Account', 'Notifications', 'Privacy']},
  {'title': 'Support', 'items': ['Help Center', 'Contact Us', 'FAQ']},
  {'title': 'About', 'items': ['Version', 'Terms', 'Licenses']},
];

class ExpandableList extends StatelessWidget {
  const ExpandableList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expandable List')),
      body: ListView.builder(
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          return ExpansionTile(
            title: Text(
              section['title'] as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: (section['items'] as List<String>)
                .map((item) => ListTile(
                      leading: const Icon(Icons.circle, size: 8),
                      title: Text(item),
                      onTap: () {},
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
