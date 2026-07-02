import 'package:flutter/material.dart';

class _Reminder {
  final String title;
  final String time;
  final IconData icon;
  bool on;
  _Reminder(this.title, this.time, this.icon, this.on);
}

class _Group {
  final String label;
  final List<_Reminder> items;
  const _Group(this.label, this.items);
}

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  final _groups = [
    _Group('Today', [
      _Reminder('Team standup', '9:30 AM', Icons.groups_outlined, true),
      _Reminder('Take medication', '1:00 PM', Icons.medication_outlined, true),
      _Reminder('Call the bank', '4:15 PM', Icons.call_outlined, false),
    ]),
    _Group('Tomorrow', [
      _Reminder('Dentist appointment', '11:00 AM', Icons.local_hospital_outlined,
          true),
      _Reminder('Pay rent', 'All day', Icons.home_outlined, true),
    ]),
    _Group('This week', [
      _Reminder('Renew passport', 'Thu', Icons.badge_outlined, false),
      _Reminder('Mom\'s birthday', 'Sat', Icons.cake_outlined, true),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
          onPressed: () {}, child: const Icon(Icons.add_alert)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final g in _groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(g.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: scheme.primary)),
            ),
            for (final r in g.items)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.surfaceContainerHighest,
                  child:
                      Icon(r.icon, size: 20, color: scheme.onSurfaceVariant),
                ),
                title: Text(r.title),
                subtitle: Text(r.time),
                trailing: Switch(
                    value: r.on, onChanged: (v) => setState(() => r.on = v)),
              ),
          ],
        ],
      ),
    );
  }
}
