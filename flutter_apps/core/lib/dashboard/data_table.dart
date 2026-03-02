import 'package:flutter/material.dart';

const _rows = [
  {'id': '001', 'name': 'Alice Smith', 'email': 'alice@example.com', 'role': 'Admin'},
  {'id': '002', 'name': 'Bob Jones', 'email': 'bob@example.com', 'role': 'User'},
  {'id': '003', 'name': 'Carol White', 'email': 'carol@example.com', 'role': 'Editor'},
  {'id': '004', 'name': 'David Brown', 'email': 'david@example.com', 'role': 'User'},
  {'id': '005', 'name': 'Eve Davis', 'email': 'eve@example.com', 'role': 'Admin'},
];

class DataTableScreen extends StatelessWidget {
  const DataTableScreen({super.key});

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
            rows: _rows.map((r) => DataRow(
              cells: [
                DataCell(Text(r['id'] as String)),
                DataCell(Text(r['name'] as String)),
                DataCell(Text(r['email'] as String)),
                DataCell(Text(r['role'] as String)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () {}),
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
