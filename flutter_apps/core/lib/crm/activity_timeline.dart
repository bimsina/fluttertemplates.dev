import 'package:flutter/material.dart';

class _Activity {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String time;
  const _Activity(this.icon, this.color, this.title, this.detail, this.time);
}

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key});

  static const _items = [
    _Activity(Icons.call, Color(0xFF42A5F5), 'Call with Amara Okafor',
        'Discussed annual pricing · 12 min', 'Today, 10:24'),
    _Activity(Icons.mail, Color(0xFF66BB6A), 'Email sent',
        'Proposal v2 delivered', 'Today, 09:10'),
    _Activity(Icons.note_alt_outlined, Color(0xFFFFB74D), 'Note added',
        'Budget approved for Q3', 'Yesterday'),
    _Activity(Icons.event_available, Color(0xFFBA68C8), 'Meeting booked',
        'Demo scheduled for Thu 2 PM', 'Yesterday'),
    _Activity(Icons.attach_money, Color(0xFF26A69A), 'Deal updated',
        'Moved to Proposal · \$22k', '2 days ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final a = _items[i];
          final isLast = i == _items.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon, size: 18, color: a.color),
                    ),
                    if (!isLast)
                      Expanded(
                          child: Container(
                              width: 2, color: scheme.outlineVariant)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(a.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text(a.time,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(a.detail,
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
