import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Security'),
              Tab(text: 'Billing'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GeneralTab(),
            _SecurityTab(),
            _BillingTab(),
          ],
        ),
      ),
    );
  }
}

class _GeneralTab extends StatelessWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          initialValue: 'Acme Inc.',
          decoration: const InputDecoration(
              labelText: 'Organization name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: 'UTC−05:00 Eastern',
          decoration: const InputDecoration(
              labelText: 'Timezone', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(
                value: 'UTC−05:00 Eastern', child: Text('UTC−05:00 Eastern')),
            DropdownMenuItem(
                value: 'UTC+00:00 London', child: Text('UTC+00:00 London')),
            DropdownMenuItem(
                value: 'UTC+05:45 Kathmandu',
                child: Text('UTC+05:45 Kathmandu')),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: true,
          onChanged: (_) {},
          title: const Text('Product update emails'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _SecurityTab extends StatelessWidget {
  const _SecurityTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SwitchListTile(
          value: true,
          onChanged: _noop,
          title: Text('Require two-factor auth'),
          subtitle: Text('For all organization members'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: false,
          onChanged: _noop,
          title: Text('Single sign-on (SSO)'),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.vpn_key_outlined),
          title: Text('Active sessions'),
          subtitle: Text('3 devices'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

void _noop(bool _) {}

class _BillingTab extends StatelessWidget {
  const _BillingTab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: scheme.primaryContainer,
          child: ListTile(
            title: const Text('Pro plan'),
            subtitle: const Text('\$49 / month · renews Aug 1'),
            trailing: TextButton(
                onPressed: () {}, child: const Text('Manage')),
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.credit_card),
          title: Text('Visa ending 4242'),
          subtitle: Text('Expires 08/27'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.receipt_long_outlined),
          title: Text('Billing history'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
