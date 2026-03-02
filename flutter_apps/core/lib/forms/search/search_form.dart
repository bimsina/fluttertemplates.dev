import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  var _category = 'All';
  var _dateRange = 'Any';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              'All',
              'Docs',
              'Images',
              'Videos',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _dateRange,
            decoration: const InputDecoration(
              labelText: 'Date Range',
              border: OutlineInputBorder(),
            ),
            items: [
              'Any',
              'Today',
              'This Week',
              'This Month',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _dateRange = v ?? _dateRange),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Option A'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Option B'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Option C'),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Search')),
        ],
      ),
    );
  }
}
