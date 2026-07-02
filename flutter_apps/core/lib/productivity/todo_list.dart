import 'package:flutter/material.dart';

class _Task {
  String text;
  bool done;
  _Task(this.text, this.done);
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _tasks = [
    _Task('Finish the design review', false),
    _Task('Reply to Amara\'s email', true),
    _Task('Buy groceries for the week', false),
    _Task('Book dentist appointment', false),
    _Task('Water the plants', true),
  ];
  final _controller = TextEditingController();

  int get _remaining => _tasks.where((t) => !t.done).length;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.insert(0, _Task(text, false));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text('$_remaining tasks remaining',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, i) {
          final t = _tasks[i];
          return Dismissible(
            key: ObjectKey(t),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => setState(() => _tasks.remove(t)),
            background: Container(
              color: scheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: scheme.onErrorContainer),
            ),
            child: CheckboxListTile(
              value: t.done,
              onChanged: (v) => setState(() => t.done = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                t.text,
                style: TextStyle(
                  decoration: t.done ? TextDecoration.lineThrough : null,
                  color: t.done ? scheme.onSurfaceVariant : scheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        color: scheme.surface,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(
                  hintText: 'Add a task…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _add, icon: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}
