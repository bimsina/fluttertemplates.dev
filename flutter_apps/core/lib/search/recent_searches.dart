import 'package:flutter/material.dart';

const _catalog = [
  'Building a responsive layout',
  'Dark mode with ColorScheme',
  'Form validation patterns',
  'Custom painters explained',
  'Navigation with nested routes',
  'State management compared',
  'Animating list items',
  'Testing widgets with goldens',
  'Writing a platform channel',
  'Reducing app size',
];

class RecentSearches extends StatefulWidget {
  const RecentSearches({super.key});

  @override
  State<RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  static const _limit = 6;

  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// Newest first. Back this with shared preferences or your API to persist it.
  var _recent = <String>['dark mode', 'navigation', 'form validation', 'testing'];

  /// The query that produced the results on screen, if any.
  String? _submitted;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Editing the text returns from results to the history view.
      if (_submitted != null && _controller.text != _submitted) {
        _submitted = null;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _search(String raw) {
    final query = raw.trim();
    if (query.isEmpty) return;
    final lower = query.toLowerCase();
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() {
      _recent = [
        query,
        ..._recent.where((r) => r.toLowerCase() != lower),
      ].take(_limit).toList();
      _submitted = query;
    });
    _focus.unfocus();
  }

  /// Copies a past query into the field so it can be refined before searching.
  void _refine(String query) {
    _controller.value = TextEditingValue(
      text: '$query ',
      selection: TextSelection.collapsed(offset: query.length + 1),
    );
    _focus.requestFocus();
  }

  void _remove(String query) {
    final index = _recent.indexOf(query);
    setState(() => _recent.removeAt(index));
    _offerUndo('Removed "$query"', () => _recent.insert(index, query));
  }

  void _clearAll() {
    final previous = _recent;
    setState(() => _recent = []);
    _offerUndo('Search history cleared', () => _recent = previous);
  }

  void _offerUndo(String message, VoidCallback restore) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(restore),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final submitted = _submitted;
    final typed = _controller.text.trim().toLowerCase();
    final history = _recent
        .where((r) => r.toLowerCase().contains(typed))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Docs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBar(
              controller: _controller,
              focusNode: _focus,
              elevation: const WidgetStatePropertyAll(0),
              hintText: 'Search the docs',
              leading: const Icon(Icons.search),
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    onPressed: _controller.clear,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),
          Expanded(
            child: submitted != null
                ? _Results(query: submitted)
                : _History(
                    items: history,
                    isFiltering: typed.isNotEmpty,
                    pendingQuery: _controller.text.trim(),
                    onSearch: _search,
                    onRefine: _refine,
                    onRemove: _remove,
                    onClearAll: _clearAll,
                  ),
          ),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({
    required this.items,
    required this.isFiltering,
    required this.pendingQuery,
    required this.onSearch,
    required this.onRefine,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<String> items;
  final bool isFiltering;
  final String pendingQuery;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onRefine;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty && !isFiltering) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 40, color: scheme.outline),
              const SizedBox(height: 12),
              Text(
                'Your recent searches will show up here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (!isFiltering)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Recent', style: theme.textTheme.titleSmall),
                ),
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
        if (isFiltering)
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(
              'Search for "$pendingQuery"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onSearch(pendingQuery),
          ),
        for (final query in items)
          ListTile(
            key: ValueKey(query),
            leading: const Icon(Icons.history),
            title: Text(query, maxLines: 1, overflow: TextOverflow.ellipsis),
            contentPadding: const EdgeInsets.only(left: 16, right: 4),
            onTap: () => onSearch(query),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Refine "$query"',
                  onPressed: () => onRefine(query),
                  icon: const Icon(Icons.north_west, size: 18),
                ),
                IconButton(
                  tooltip: 'Remove "$query"',
                  onPressed: () => onRemove(query),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final words = query.toLowerCase().split(RegExp(r'\s+'));
    final hits = _catalog
        .where((title) => words.any(title.toLowerCase().contains))
        .toList();

    if (hits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nothing found for "$query"',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: hits.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.article_outlined),
        title: Text(hits[index]),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDemo(context, 'Open ${hits[index]} (demo)'),
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
