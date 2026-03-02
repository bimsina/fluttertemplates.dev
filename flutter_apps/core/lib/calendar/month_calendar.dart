import 'package:flutter/material.dart';

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({super.key});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  var _selectedDate = DateTime(2025, 3, 15);
  final _events = {15: 2, 18: 1, 22: 3};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('March 2025'),
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => SizedBox(
                        width: 40,
                        child: Text(d, style: Theme.of(context).textTheme.labelSmall),
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
              itemCount: 35,
              itemBuilder: (context, i) {
                final day = i - 5;
                final hasEvent = day > 0 && _events.containsKey(day);
                final isSelected = day == _selectedDate.day;
                return GestureDetector(
                  onTap: day > 0
                      ? () => setState(() => _selectedDate = DateTime(2025, 3, day))
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : hasEvent
                              ? Colors.blue.withValues(alpha: 0.2)
                              : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: day > 0
                          ? Text(
                              '$day',
                              style: TextStyle(
                                color: isSelected ? Colors.white : null,
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            )
                          : null,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'March 15',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Meeting'),
                    subtitle: const Text('10:00 AM'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Lunch'),
                    subtitle: const Text('12:30 PM'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
