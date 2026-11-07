import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  /// Called with the query and filters once the query isn't empty. Without
  /// it the demo shows a SnackBar.
  final void Function(
    String query,
    String category,
    String dateRange,
    Set<String> options,
  )? onSearch;

  const SearchForm({super.key, this.onSearch});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  var _category = 'All';
  var _dateRange = 'Any';
  final _queryController = TextEditingController();
  final _options = {'Option C'};
  String? _queryError;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _toggleOption(String option, bool selected) {
    setState(() {
      selected ? _options.add(option) : _options.remove(option);
    });
  }

  void _search() {
    final query = _queryController.text.trim();
    setState(() => _queryError = query.isEmpty ? 'Enter a search term' : null);
    if (query.isEmpty) return;

    final onSearch = widget.onSearch;
    if (onSearch != null) {
      onSearch(query, _category, _dateRange, {..._options});
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Searching $_category for "$query" (demo)'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _queryController,
            onChanged: (_) {
              if (_queryError != null) setState(() => _queryError = null);
            },
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Search',
              errorText: _queryError,
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
              for (final option in ['Option A', 'Option B', 'Option C'])
                FilterChip(
                  label: Text(option),
                  selected: _options.contains(option),
                  onSelected: (selected) => _toggleOption(option, selected),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _search, child: const Text('Search')),
        ],
      ),
    );
  }
}
