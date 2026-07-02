import 'package:flutter/material.dart';

class _Member {
  final String name;
  final String email;
  final String role;
  final bool pending;
  const _Member(this.name, this.email, this.role, {this.pending = false});
}

class TeamMembers extends StatelessWidget {
  const TeamMembers({super.key});

  static const _members = [
    _Member('Alex Kim', 'alex@acme.io', 'Owner'),
    _Member('Bianca Rossi', 'bianca@acme.io', 'Admin'),
    _Member('Chen Wei', 'chen@acme.io', 'Member'),
    _Member('Dana Ford', 'dana@acme.io', 'Member'),
    _Member('priya@acme.io', 'Invitation sent', 'Member', pending: true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.people, color: scheme.primary),
                const SizedBox(width: 12),
                const Text('9 of 10 seats used',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Invite')),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _members.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = _members[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: m.pending
                        ? scheme.surfaceContainerHighest
                        : scheme.primaryContainer,
                    child: m.pending
                        ? const Icon(Icons.hourglass_empty, size: 18)
                        : Text(m.name[0]),
                  ),
                  title: Text(m.name),
                  subtitle: Text(m.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.outlineVariant),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(m.role,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
