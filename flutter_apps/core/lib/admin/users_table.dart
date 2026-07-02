import 'package:flutter/material.dart';

class _User {
  final String name;
  final String email;
  final String role;
  final String status;
  const _User(this.name, this.email, this.role, this.status);
}

class UsersTable extends StatelessWidget {
  const UsersTable({super.key});

  static const _users = [
    _User('Alex Kim', 'alex@acme.io', 'Admin', 'Active'),
    _User('Bianca Rossi', 'bianca@acme.io', 'Editor', 'Active'),
    _User('Chen Wei', 'chen@acme.io', 'Viewer', 'Invited'),
    _User('Dana Ford', 'dana@acme.io', 'Editor', 'Suspended'),
    _User('Elias Bauer', 'elias@acme.io', 'Admin', 'Active'),
    _User('Farah Nasser', 'farah@acme.io', 'Viewer', 'Active'),
  ];

  Color _statusColor(BuildContext context, String s) {
    switch (s) {
      case 'Active':
        return Colors.green;
      case 'Invited':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add user')),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 320,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    for (final u in _users)
                      DataRow(cells: [
                        DataCell(Row(
                          children: [
                            CircleAvatar(
                                radius: 14,
                                child: Text(u.name[0],
                                    style: const TextStyle(fontSize: 12))),
                            const SizedBox(width: 10),
                            Text(u.name),
                          ],
                        )),
                        DataCell(Text(u.email)),
                        DataCell(Text(u.role)),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(context, u.status)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(u.status,
                              style: TextStyle(
                                  color: _statusColor(context, u.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        )),
                        DataCell(PopupMenuButton<String>(
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'remove', child: Text('Remove')),
                          ],
                        )),
                      ]),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Showing 1–6 of 128',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left)),
                const Text('1'),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
