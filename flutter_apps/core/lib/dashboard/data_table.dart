import 'package:flutter/material.dart';

const _rows = [
  {'id': '001', 'name': 'Alice Smith', 'email': 'alice@example.com', 'role': 'Admin'},
  {'id': '002', 'name': 'Bob Jones', 'email': 'bob@example.com', 'role': 'User'},
  {'id': '003', 'name': 'Carol White', 'email': 'carol@example.com', 'role': 'Editor'},
  {'id': '004', 'name': 'David Brown', 'email': 'david@example.com', 'role': 'User'},
  {'id': '005', 'name': 'Eve Davis', 'email': 'eve@example.com', 'role': 'Admin'},
];

class DataTableScreen extends StatefulWidget {
  const DataTableScreen({super.key});

  @override
  State<DataTableScreen> createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  final _users = [..._rows];

  Future<void> _confirmDelete(Map<String, String> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Delete ${user['name']}?'),
        content: const Text('This removes the user from the table.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) setState(() => _users.remove(user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Table')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _users.map((r) => DataRow(
              cells: [
                DataCell(Text(r['id'] as String)),
                DataCell(Text(r['name'] as String)),
                DataCell(Text(r['email'] as String)),
                DataCell(Text(r['role'] as String)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(tooltip: 'Edit user', icon: const Icon(Icons.edit, size: 18), onPressed: () => _showDemo(context, 'Edit ${r['name']} (demo)')),
                    IconButton(tooltip: 'Delete user', icon: const Icon(Icons.delete, size: 18), onPressed: () => _confirmDelete(r)),
                  ],
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
