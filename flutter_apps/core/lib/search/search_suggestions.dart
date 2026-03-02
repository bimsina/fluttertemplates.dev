import 'package:flutter/material.dart';

const _recent = ['flutter', 'dart', 'widgets'];
const _trending = ['Flutter 3.0', 'Riverpod', 'Go Router'];

class SearchSuggestions extends StatefulWidget {
  const SearchSuggestions({super.key});

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  final _controller = TextEditingController();
  var _suggestions = <String>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final q = _controller.text.toLowerCase();
      if (q.isEmpty) {
        setState(() => _suggestions = []);
      } else {
        setState(() => _suggestions = _recent
            .where((s) => s.contains(q))
            .toList());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      ),
      body: ListView(
        children: [
          if (_suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Suggestions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ..._suggestions.map(
              (s) => ListTile(
                leading: const Icon(Icons.search),
                title: Text(s),
                onTap: () {},
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ..._recent.map(
            (s) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(s),
              onTap: () => _controller.text = s,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Trending',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ..._trending.map(
            (s) => ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(s),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
