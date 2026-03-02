import 'package:flutter/material.dart';

const _features = [
  {'name': 'Projects', 'free': '3', 'pro': 'Unlimited', 'enterprise': 'Unlimited'},
  {'name': 'Storage', 'free': '1 GB', 'pro': '10 GB', 'enterprise': '100 GB'},
  {'name': 'Support', 'free': 'Email', 'pro': 'Priority', 'enterprise': 'Dedicated'},
  {'name': 'API Access', 'free': '—', 'pro': '✓', 'enterprise': '✓'},
];

class FeatureComparison extends StatelessWidget {
  const FeatureComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Plans')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Feature')),
            DataColumn(label: Text('Free')),
            DataColumn(label: Text('Pro')),
            DataColumn(label: Text('Enterprise')),
          ],
          rows: _features.map((f) => DataRow(
            cells: [
              DataCell(Text(f['name'] as String)),
              DataCell(Text(f['free'] as String)),
              DataCell(Text(f['pro'] as String)),
              DataCell(Text(f['enterprise'] as String)),
            ],
          )).toList(),
        ),
      ),
    );
  }
}
