import 'package:flutter/material.dart';

class EditForm extends StatefulWidget {
  const EditForm({super.key});

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  String _role = 'Editor';
  bool _active = true;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit user'),
        actions: [TextButton(onPressed: () {}, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                const CircleAvatar(radius: 40, child: Text('AK')),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.edit,
                        size: 14, color: theme.colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'Profile'),
          TextFormField(
            initialValue: 'Alex Kim',
            decoration: const InputDecoration(
                labelText: 'Full name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: 'alex@acme.io',
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'Access'),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(
                labelText: 'Role', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Editor', child: Text('Editor')),
              DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
            ],
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: const Text('Account active'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _twoFactor,
            onChanged: (v) => setState(() => _twoFactor = v),
            title: const Text('Require two-factor auth'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: () {}, child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                    onPressed: () {}, child: const Text('Save changes')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}
