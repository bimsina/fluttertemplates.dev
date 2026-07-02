import 'package:flutter/material.dart';

class _Event {
  final String actor;
  final String action;
  final String time;
  final IconData icon;
  const _Event(this.actor, this.action, this.time, this.icon);
}

class ActivityLog extends StatelessWidget {
  const ActivityLog({super.key});

  static const _events = [
    _Event('Alex Kim', 'updated billing settings', '2 min ago', Icons.payment),
    _Event('System', 'ran nightly backup', '1 hour ago', Icons.backup_outlined),
    _Event('Bianca Rossi', 'invited chen@acme.io', '3 hours ago',
        Icons.person_add_outlined),
    _Event('Dana Ford', 'deleted a project', 'Yesterday',
        Icons.delete_outline),
    _Event('Alex Kim', 'changed a user role to Admin', 'Yesterday',
        Icons.admin_panel_settings_outlined),
    _Event('Elias Bauer', 'signed in from a new device', '2 days ago',
        Icons.login),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity log'),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, i) {
          final e = _events[i];
          final isLast = i == _events.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(e.icon,
                          size: 18, color: scheme.onPrimaryContainer),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: scheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: e.actor,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          TextSpan(text: ' ${e.action}'),
                        ])),
                        const SizedBox(height: 4),
                        Text(e.time,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
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
