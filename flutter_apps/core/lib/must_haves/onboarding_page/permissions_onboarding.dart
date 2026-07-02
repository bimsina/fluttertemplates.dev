import 'package:flutter/material.dart';

class _Perm {
  final IconData icon;
  final String title;
  final String why;
  const _Perm(this.icon, this.title, this.why);
}

class PermissionsOnboarding extends StatefulWidget {
  const PermissionsOnboarding({super.key});

  @override
  State<PermissionsOnboarding> createState() => _PermissionsOnboardingState();
}

class _PermissionsOnboardingState extends State<PermissionsOnboarding> {
  static const _perms = [
    _Perm(Icons.notifications_outlined, 'Notifications',
        'Get reminders and important updates.'),
    _Perm(Icons.location_on_outlined, 'Location',
        'Show places and offers near you.'),
    _Perm(Icons.camera_alt_outlined, 'Camera',
        'Scan documents and add photos.'),
    _Perm(Icons.contacts_outlined, 'Contacts',
        'Find friends who already use the app.'),
  ];

  final _granted = <int>{0};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A few permissions',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('You can change these anytime in Settings.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _perms.length,
                itemBuilder: (context, i) {
                  final p = _perms[i];
                  final granted = _granted.contains(i);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(p.icon,
                                color: scheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(p.why,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          granted
                              ? FilledButton.tonal(
                                  onPressed: () =>
                                      setState(() => _granted.remove(i)),
                                  child: const Text('Allowed'),
                                )
                              : OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _granted.add(i)),
                                  child: const Text('Allow'),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                    onPressed: () {}, child: const Text('Continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
