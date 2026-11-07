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

class _GeneralTab extends StatefulWidget {
  const _GeneralTab();

  @override
  State<_GeneralTab> createState() => _GeneralTabState();
}

// TabBarView disposes tabs that scroll away, so keep this one alive.
class _GeneralTabState extends State<_GeneralTab>
    with AutomaticKeepAliveClientMixin {
  bool _productEmails = true;
  String _timezone = 'UTC−05:00 Eastern';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          initialValue: _timezone,
          isExpanded: true,
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
          onChanged: (v) => setState(() => _timezone = v ?? _timezone),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _productEmails,
          onChanged: (v) => setState(() => _productEmails = v),
          title: const Text('Product update emails'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _SecurityTab extends StatefulWidget {
  const _SecurityTab();

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab>
    with AutomaticKeepAliveClientMixin {
  bool _requireTwoFactor = true;
  bool _singleSignOn = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: _requireTwoFactor,
          onChanged: (v) => setState(() => _requireTwoFactor = v),
          title: const Text('Require two-factor auth'),
          subtitle: const Text('For all organization members'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _singleSignOn,
          onChanged: (v) => setState(() => _singleSignOn = v),
          title: const Text('Single sign-on (SSO)'),
          contentPadding: EdgeInsets.zero,
        ),
        const ListTile(
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
                onPressed: () => _showDemo(context, 'Manage (demo)'), child: const Text('Manage')),
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

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
