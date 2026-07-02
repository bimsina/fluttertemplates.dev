import 'package:flutter/material.dart';

class _Session {
  final String time;
  final String title;
  final String room;
  final bool keynote;
  const _Session(this.time, this.title, this.room, {this.keynote = false});
}

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int _day = 0;
  static const _days = ['Thu 11', 'Fri 12', 'Sat 13'];

  static const _sessions = [
    _Session('09:00', 'Opening keynote', 'Main Hall', keynote: true),
    _Session('10:30', 'Building for the web with Flutter', 'Room A'),
    _Session('12:00', 'Lunch break', 'Foyer'),
    _Session('13:30', 'State management deep dive', 'Room B'),
    _Session('15:00', 'Designing for accessibility', 'Room A'),
    _Session('16:30', 'Lightning talks', 'Main Hall'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Center(
                child: ChoiceChip(
                  label: Text(_days[i]),
                  selected: _day == i,
                  onSelected: (_) => setState(() => _day = i),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (context, i) {
                final s = _sessions[i];
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(s.time,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant)),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: s.keynote
                                  ? scheme.primary
                                  : scheme.surface,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: scheme.primary, width: 2),
                            ),
                          ),
                          if (i != _sessions.length - 1)
                            Expanded(
                                child: Container(
                                    width: 2,
                                    color: scheme.outlineVariant)),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: s.keynote
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.room,
                                      size: 14,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(s.room,
                                      style: TextStyle(
                                          color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
