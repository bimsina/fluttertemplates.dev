import 'package:flutter/material.dart';

const _results = [
  {
    'title': 'Flutter Documentation',
    'snippet': 'Official Flutter docs...',
    'type': 'Pages',
    'daysOld': 12,
  },
  {
    'title': 'Flutter Packages',
    'snippet': 'Pub.dev package search...',
    'type': 'Pages',
    'daysOld': 3,
  },
  {
    'title': 'Flutter Logo Assets',
    'snippet': 'Brand images and icons...',
    'type': 'Images',
    'daysOld': 40,
  },
  {
    'title': 'Flutter Layout Basics',
    'snippet': 'A short intro video...',
    'type': 'Videos',
    'daysOld': 1,
  },
];

const _filters = ['All', 'Images', 'Videos'];

class SearchResults extends StatefulWidget {
  const SearchResults({super.key});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  var _query = '';
  var _filter = _filters.first;
  var _sort = 'Relevance';

  List<Map<String, Object>> get _visible {
    final query = _query.trim().toLowerCase();
    final results = _results.where((r) {
      final title = (r['title'] as String).toLowerCase();
      return (_filter == 'All' || r['type'] == _filter) &&
          title.contains(query);
    }).toList();
    if (_sort == 'Date') {
      results.sort(
        (a, b) => (a['daysOld'] as int).compareTo(b['daysOld'] as int),
      );
    }
    return results;
  }

  // Bolds each case-insensitive match of the query in [title].
  TextSpan _highlight(String title, TextStyle? matchStyle) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return TextSpan(text: title);
    final lower = title.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    for (
      var match = lower.indexOf(query);
      match != -1;
      match = lower.indexOf(query, start)
    ) {
      spans.add(TextSpan(text: title.substring(start, match)));
      start = match + query.length;
      spans.add(
        TextSpan(text: title.substring(match, start), style: matchStyle),
      );
    }
    spans.add(TextSpan(text: title.substring(start)));
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
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
                for (final filter in _filters) ...[
                  FilterChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                  const SizedBox(width: 8),
                ],
                DropdownButton<String>(
                  value: _sort,
                  items: ['Relevance', 'Date']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sort = v ?? _sort),
                ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No results'))
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final r = visible[i];
                      return ListTile(
                        title: Text.rich(
                          _highlight(
                            r['title'] as String,
                            TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ),
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
