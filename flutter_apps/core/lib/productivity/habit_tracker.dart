import 'package:flutter/material.dart';

const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar arithmetic instead of adding a Duration, which drifts by an hour
/// across daylight saving changes.
DateTime _addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

class _Habit {
  _Habit(this.name, this.icon, this.done);

  final String name;
  final IconData icon;
  final Set<DateTime> done;

  /// Consecutive days ending today, or yesterday if today is still open.
  int streak(DateTime today) {
    var day = done.contains(today) ? today : _addDays(today, -1);
    var count = 0;
    while (done.contains(day)) {
      count++;
      day = _addDays(day, -1);
    }
    return count;
  }
}

class HabitTracker extends StatefulWidget {
  const HabitTracker({super.key});

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  final _today = _dateOnly(DateTime.now());
  late final _habits = [
    _Habit('Read 20 pages', Icons.menu_book_outlined, _history([1, 2, 3, 4, 6])),
    _Habit('Morning run', Icons.directions_run, _history([0, 1, 2, 5, 8, 9])),
    _Habit('No phone in bed', Icons.bedtime_outlined, _history([2, 3, 7, 10])),
    _Habit('Drink 2L water', Icons.water_drop_outlined,
        _history([1, 2, 3, 4, 5, 6, 7, 8, 9])),
  ];

  /// Index 0 is the current week, -1 the one before. Future weeks are blocked.
  var _weekOffset = 0;

  Set<DateTime> _history(List<int> daysAgo) =>
      {for (final d in daysAgo) _addDays(_today, -d)};

  DateTime get _weekStart => _addDays(
        _today,
        -(_today.weekday - 1) + _weekOffset * 7,
      );

  void _toggle(_Habit habit, DateTime day) {
    setState(() {
      if (!habit.done.remove(day)) habit.done.add(day);
    });
  }

  Future<void> _addHabit() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New habit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Stretch for 5 minutes'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    setState(() => _habits.add(_Habit(name.trim(), Icons.star_outline, {})));
  }

  void _delete(_Habit habit) {
    final index = _habits.indexOf(habit);
    setState(() => _habits.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed "${habit.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => _habits.insert(index, habit)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final doneToday = _habits.where((h) => h.done.contains(_today)).length;
    final weekEnd = _addDays(_weekStart, 6);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add habit',
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          Text(
            '$doneToday of ${_habits.length} done today',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                end: _habits.isEmpty ? 0 : doneToday / _habits.length,
              ),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous week',
                onPressed: () => setState(() => _weekOffset--),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _weekOffset == 0
                      ? 'This week'
                      : '${_weekStart.day}/${_weekStart.month} – '
                          '${weekEnd.day}/${weekEnd.month}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              IconButton(
                tooltip: 'Next week',
                onPressed: _weekOffset == 0
                    ? null
                    : () => setState(() => _weekOffset++),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          for (final habit in _habits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HabitCard(
                key: ObjectKey(habit),
                habit: habit,
                today: _today,
                weekStart: _weekStart,
                onToggle: (day) => _toggle(habit, day),
                onDelete: () => _delete(habit),
              ),
            ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    super.key,
    required this.habit,
    required this.today,
    required this.weekStart,
    required this.onToggle,
    required this.onDelete,
  });

  final _Habit habit;
  final DateTime today;
  final DateTime weekStart;
  final ValueChanged<DateTime> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final streak = habit.streak(today);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(habit.icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 16,
                  color:
                      streak > 0 ? scheme.tertiary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text('$streak', style: theme.textTheme.labelMedium),
                IconButton(
                  tooltip: 'Remove habit',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    _DayDot(
                      label: _weekdays[i],
                      day: _addDays(weekStart, i),
                      today: today,
                      done: habit.done.contains(_addDays(weekStart, i)),
                      onTap: () => onToggle(_addDays(weekStart, i)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.day,
    required this.today,
    required this.done,
    required this.onTap,
  });

  final String label;
  final DateTime day;
  final DateTime today;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFuture = day.isAfter(today);
    final isToday = day == today;

    return Semantics(
      button: true,
      toggled: done,
      enabled: !isFuture,
      label: '${day.day}/${day.month}',
      child: InkResponse(
        onTap: isFuture ? null : onTap,
        radius: 22,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? scheme.primary : scheme.surfaceContainerHighest,
            border: isToday
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          child: done
              ? Icon(Icons.check, size: 18, color: scheme.onPrimary)
              : Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isFuture
                        ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
                        : scheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
