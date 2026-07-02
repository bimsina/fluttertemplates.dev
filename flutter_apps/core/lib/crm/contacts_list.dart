import 'package:flutter/material.dart';

class _Contact {
  final String name;
  final String company;
  const _Contact(this.name, this.company);
}

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  static const _contacts = [
    _Contact('Amara Okafor', 'Northwind Ltd'),
    _Contact('Ben Carter', 'Acme Corp'),
    _Contact('Bianca Rossi', 'Vertex Labs'),
    _Contact('Carlos Diaz', 'Sunrise Media'),
    _Contact('Dana Ford', 'Bluewave'),
    _Contact('Elena Petrova', 'Orbit Studio'),
    _Contact('Farah Nasser', 'Cedar & Co'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Group by first letter.
    final grouped = <String, List<_Contact>>{};
    for (final c in _contacts) {
      grouped.putIfAbsent(c.name[0], () => []).add(c);
    }
    final letters = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          for (final letter in letters) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(letter,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.primary)),
            ),
            for (final c in grouped[letter]!)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Text(c.name[0],
                      style: TextStyle(color: scheme.onPrimaryContainer)),
                ),
                title: Text(c.name),
                subtitle: Text(c.company),
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call_outlined)),
              ),
          ],
        ],
      ),
    );
  }
}
