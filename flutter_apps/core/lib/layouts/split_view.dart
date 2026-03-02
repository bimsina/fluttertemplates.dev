import 'package:flutter/material.dart';

const _items = ['Inbox', 'Sent', 'Drafts', 'Trash'];
const _emails = [
  {'from': 'Alice', 'subj': 'Meeting tomorrow'},
  {'from': 'Bob', 'subj': 'Project update'},
  {'from': 'Charlie', 'subj': 'Lunch plans'},
];

class SplitView extends StatefulWidget {
  const SplitView({super.key});

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  int _selectedIndex = 0;
  int? _selectedEmail;
  var _showDetail = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split View')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          if (isNarrow) {
            return _buildNarrowLayout();
          }
          return Row(
            children: [
              SizedBox(
                width: 250,
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: Icon(_icons[i]),
                    title: Text(_items[i]),
                    selected: _selectedIndex == i,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                        itemCount: _emails.length,
                        itemBuilder: (context, i) {
                          final e = _emails[i];
                          return ListTile(
                            title: Text(e['from'] as String),
                            subtitle: Text(e['subj'] as String),
                            selected: _selectedEmail == i,
                            onTap: () =>
                                setState(() => _selectedEmail = i),
                          );
                        },
                      ),
                    ),
                    if (_showDetail && _selectedEmail != null)
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _emails[_selectedEmail!]['subj']
                                          as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(
                                          () => _showDetail = false),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                    'Email content goes here. This is the master-detail layout pattern.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const _icons = [
    Icons.inbox,
    Icons.send,
    Icons.drafts,
    Icons.delete,
  ];

  Widget _buildNarrowLayout() {
    if (_selectedEmail != null && _showDetail) {
      return Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _showDetail = false),
            ),
            title: Text(_emails[_selectedEmail!]['subj'] as String),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Email content. On mobile, the detail collapses to a single pane.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < _emails.length; i++)
                ListTile(
                  title: Text(_emails[i]['from'] as String),
                  subtitle: Text(_emails[i]['subj'] as String),
                  onTap: () => setState(() {
                    _selectedEmail = i;
                    _showDetail = true;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
