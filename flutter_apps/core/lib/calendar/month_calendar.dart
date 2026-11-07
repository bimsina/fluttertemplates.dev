import 'package:flutter/material.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class _Event {
  final String title;
  final String time;
  const _Event(this.title, this.time);
}

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({super.key});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  late final Map<DateTime, List<_Event>> _events;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    // Sample data around today, so the demo always has something to show.
    _events = {
      _selectedDate: const [
        _Event('Meeting', '10:00 AM'),
        _Event('Lunch', '12:30 PM'),
      ],
      DateTime(now.year, now.month, now.day + 3): const [
        _Event('Design review', '2:00 PM'),
      ],
      DateTime(now.year, now.month, now.day + 7): const [
        _Event('Team offsite', '9:00 AM'),
        _Event('Dinner', '7:00 PM'),
      ],
    };
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
      _selectedDate = _displayedMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    // The grid starts on Monday, and DateTime.weekday is 1 for Monday.
    final leadingBlanks = DateTime(year, month, 1).weekday - 1;
    // Day 0 of the next month is the last day of this one.
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final cellCount = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;
    final agenda = _events[_selectedDate] ?? const <_Event>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_monthNames[month - 1]} $year'),
        leading: IconButton(
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),
        actions: [
          IconButton(
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: cellCount,
              itemBuilder: (context, i) {
                final day = i - leadingBlanks + 1;
                if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

                final date = DateTime(year, month, day);
                final hasEvent = _events.containsKey(date);
                final isSelected = date == _selectedDate;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primary
                          : hasEvent
                              ? scheme.primaryContainer
                              : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected
                              ? scheme.onPrimary
                              : hasEvent
                                  ? scheme.onPrimaryContainer
                                  : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.day}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (agenda.isEmpty)
                      Text(
                        'No events',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    for (final event in agenda)
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(event.title),
                        subtitle: Text(event.time),
                        onTap: () => _showDemo(context, 'Open ${event.title} (demo)'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
