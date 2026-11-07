import 'package:flutter/material.dart';

const _columns = [
  {'title': 'To Do', 'color': Colors.grey, 'tasks': ['Task 1', 'Task 2', 'Task 3']},
  {'title': 'In Progress', 'color': Colors.blue, 'tasks': ['Task 4', 'Task 5']},
  {'title': 'Review', 'color': Colors.orange, 'tasks': ['Task 6']},
  {'title': 'Done', 'color': Colors.green, 'tasks': ['Task 7', 'Task 8']},
];

typedef _DraggedTask = ({String task, int from});

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  // Mutable copies, because the lists in `_columns` are const.
  final _tasks = [
    for (final col in _columns) List<String>.of(col['tasks'] as List<String>),
  ];
  EdgeDraggingAutoScroller? _autoScroller;
  Rect _dragRect = Rect.zero;

  void _moveTask(_DraggedTask dragged, int to) {
    setState(() {
      _tasks[dragged.from].remove(dragged.task);
      _tasks[to].add(dragged.task);
    });
  }

  void _autoScroll() => _autoScroller?.startAutoScrollIfNecessary(_dragRect);

  void _stopAutoScroll() {
    _autoScroller?.stopAutoScroll();
    _autoScroller = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Board')),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: constraints.maxHeight - 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _columns.length; i++) _buildColumn(i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(int index) {
    final col = _columns[index];
    final color = col['color'] as Color;
    final tasks = _tasks[index];

    return SizedBox(
      width: 220,
      child: DragTarget<_DraggedTask>(
        onWillAcceptWithDetails: (details) => details.data.from != index,
        onAcceptWithDetails: (details) => _moveTask(details.data, index),
        builder: (context, candidates, _) => Card(
          margin: const EdgeInsets.only(right: 16),
          color: candidates.isEmpty ? null : color.withValues(alpha: 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Text(col['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text('${tasks.length}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) => _buildTask(context, tasks[i], index),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                  onPressed: () => _showDemo(context, 'Add card (demo)'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTask(BuildContext context, String task, int column) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(task),
      ),
    );

    return LongPressDraggable<_DraggedTask>(
      data: (task: task, from: column),
      feedback: SizedBox(width: 188, child: card),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      // Scrolls the board while a task is held near the left or right edge,
      // so off-screen columns can still be reached.
      onDragStarted: () => _autoScroller = EdgeDraggingAutoScroller(
        Scrollable.of(context, axis: Axis.horizontal),
        velocityScalar: 20,
        onScrollViewScrolled: _autoScroll,
      ),
      onDragUpdate: (details) {
        _dragRect = Rect.fromCenter(
          center: details.globalPosition,
          width: 96,
          height: 48,
        );
        _autoScroll();
      },
      onDragEnd: (_) => _stopAutoScroll(),
      child: card,
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
