import 'package:flutter/material.dart';

enum _Area { work, personal, health }

extension on _Area {
  String get label => switch (this) {
        _Area.work => 'Work',
        _Area.personal => 'Personal',
        _Area.health => 'Health',
      };

  IconData get icon => switch (this) {
        _Area.work => Icons.work_outline,
        _Area.personal => Icons.home_outlined,
        _Area.health => Icons.favorite_outline,
      };
}

class _Task {
  _Task(this.title, this.area, this.day);

  final String title;
  final _Area area;
  DateTime day;
  var done = false;
}

const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime _addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

DateTime _monday(DateTime d) => _addDays(d, -(d.weekday - 1));

class WeeklyPlanner extends StatefulWidget {
  const WeeklyPlanner({super.key});

  @override
  State<WeeklyPlanner> createState() => _WeeklyPlannerState();
}

class _WeeklyPlannerState extends State<WeeklyPlanner> {
  final _today = () {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }();

  late var _weekStart = _monday(_today);
  late var _selected = _today;
  late final _tasks = _seedTasks();

  List<_Task> _seedTasks() {
    final monday = _monday(_today);
    return [
      _Task('Sprint planning', _Area.work, monday),
      _Task('Book dentist', _Area.personal, monday),
      _Task('Gym, upper body', _Area.health, _addDays(monday, 1)),
      _Task('Write release notes', _Area.work, _addDays(monday, 2)),
      _Task('Review pull requests', _Area.work, _today),
      _Task('Call parents', _Area.personal, _today),
      _Task('30 minute walk', _Area.health, _today),
      _Task('Quarterly review prep', _Area.work, _addDays(monday, 4)),
      _Task('Meal prep', _Area.health, _addDays(monday, 6)),
    ];
  }

  List<_Task> _tasksOn(DateTime day) =>
      _tasks.where((t) => t.day == day).toList();

  void _shiftWeek(int weeks) {
    setState(() {
      _weekStart = _addDays(_weekStart, weeks * 7);
      _selected = _addDays(_selected, weeks * 7);
    });
  }

  void _move(_Task task, DateTime day) {
    if (task.day == day) return;
    final from = task.day;
    setState(() => task.day = day);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Moved to ${_dayNames[day.weekday - 1]}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => task.day = from),
          ),
        ),
      );
  }

  Future<void> _addTask() async {
    final task = await showModalBottomSheet<_Task>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _AddTaskSheet(day: _selected),
    );
    if (task != null) setState(() => _tasks.add(task));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tasks = _tasksOn(_selected);
    final weekEnd = _addDays(_weekStart, 6);
    final range = '${_monthNames[_weekStart.month - 1]} ${_weekStart.day} – '
        '${_monthNames[weekEnd.month - 1]} ${weekEnd.day}';

    return Scaffold(
      appBar: AppBar(
        title: Text(range),
        actions: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: () => _shiftWeek(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next week',
            onPressed: () => _shiftWeek(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add task',
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _DayCell(
                      day: _addDays(_weekStart, i),
                      isToday: _addDays(_weekStart, i) == _today,
                      selected: _addDays(_weekStart, i) == _selected,
                      tasks: _tasksOn(_addDays(_weekStart, i)),
                      onTap: () => setState(
                        () => _selected = _addDays(_weekStart, i),
                      ),
                      onDrop: (task) => _move(task, _addDays(_weekStart, i)),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'Nothing planned for ${_dayNames[_selected.weekday - 1]}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Hold a task and drag it onto another day.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      for (final task in tasks)
                        _TaskTile(
                          key: ObjectKey(task),
                          task: task,
                          onToggle: () =>
                              setState(() => task.done = !task.done),
                          onDelete: () => setState(() => _tasks.remove(task)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.selected,
    required this.tasks,
    required this.onTap,
    required this.onDrop,
  });

  final DateTime day;
  final bool isToday;
  final bool selected;
  final List<_Task> tasks;
  final VoidCallback onTap;
  final ValueChanged<_Task> onDrop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final open = tasks.where((t) => !t.done).length;

    return DragTarget<_Task>(
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary
                  : hovering
                      ? scheme.primaryContainer
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hovering || (isToday && !selected)
                    ? scheme.primary
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _dayNames[day.weekday - 1],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.day}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: foreground),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 12,
                  child: open == 0
                      ? null
                      : Text(
                          '$open',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            height: 1.2,
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final _Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final tile = Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: Row(
        children: [
          Checkbox(value: task.done, onChanged: (_) => onToggle()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: task.done ? TextDecoration.lineThrough : null,
                    color: task.done
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      task.area.icon,
                      size: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.area.label,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );

    return LongPressDraggable<_Task>(
      data: task,
      // The drag starts quickly so it feels direct with a mouse in the preview.
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        elevation: 6,
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: tile),
      child: tile,
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.day});

  final DateTime day;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _controller = TextEditingController();
  var _area = _Area.work;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(context, _Task(title, _area, widget.day));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Task for ${_dayNames[widget.day.weekday - 1]}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final area in _Area.values)
                ChoiceChip(
                  label: Text(area.label),
                  avatar: Icon(area.icon, size: 16),
                  showCheckmark: false,
                  selected: area == _area,
                  onSelected: (_) => setState(() => _area = area),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _submit, child: const Text('Add task')),
        ],
      ),
    );
  }
}
