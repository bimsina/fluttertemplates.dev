import 'package:flutter/material.dart';

class LeadDetail extends StatelessWidget {
  const LeadDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.edit))],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(radius: 36, child: Text('AO')),
                const SizedBox(height: 12),
                Text('Amara Okafor',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('VP Marketing · Northwind Ltd',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _action(scheme, Icons.call, 'Call'),
                    _action(scheme, Icons.mail_outline, 'Email'),
                    _action(scheme, Icons.event, 'Meet'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: _stat(scheme, 'Deal value', '\$12,400')),
                const SizedBox(width: 12),
                Expanded(child: _stat(scheme, 'Stage', 'Proposal')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const ListTile(
              leading: Icon(Icons.mail_outline),
              title: Text('amara@northwind.com')),
          const ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('+1 (555) 019-2837')),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Recent activity',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          _activity(scheme, Icons.call, 'Call · 12 min', 'Yesterday'),
          _activity(
              scheme, Icons.mail, 'Sent proposal v2', '2 days ago'),
          _activity(scheme, Icons.note_alt_outlined,
              'Note: interested in annual plan', '4 days ago'),
        ],
      ),
    );
  }

  Widget _action(ColorScheme scheme, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stat(ColorScheme scheme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _activity(
      ColorScheme scheme, IconData icon, String title, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.surfaceContainerHighest,
        child: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
      ),
      title: Text(title),
      trailing: Text(time,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
    );
  }
}
