import 'package:flutter/material.dart';

class _Integration {
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final bool connected;
  const _Integration(
      this.name, this.category, this.icon, this.color, this.connected);
}

class Integrations extends StatefulWidget {
  const Integrations({super.key});

  @override
  State<Integrations> createState() => _IntegrationsState();
}

class _IntegrationsState extends State<Integrations> {
  static const _items = [
    _Integration('Slack', 'Messaging', Icons.tag, Color(0xFF611F69), true),
    _Integration('GitHub', 'Dev tools', Icons.code, Color(0xFF24292E), true),
    _Integration(
        'Stripe', 'Payments', Icons.credit_card, Color(0xFF635BFF), false),
    _Integration(
        'Notion', 'Docs', Icons.description, Color(0xFF000000), false),
    _Integration('Zapier', 'Automation', Icons.bolt, Color(0xFFFF4A00), true),
    _Integration('Figma', 'Design', Icons.brush, Color(0xFFF24E1E), false),
  ];

  late final _connected = {
    for (final it in _items)
      if (it.connected) it.name,
  };

  void _toggle(String name) {
    setState(() {
      if (!_connected.add(name)) _connected.remove(name);
    });
  }

  Future<void> _confirmDisconnect(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Disconnect $name?'),
        content: Text('$name will stop syncing until you connect it again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) _toggle(name);
  }

  Widget _tile(_Integration it, ColorScheme scheme) {
    const buttonPadding = EdgeInsets.symmetric(horizontal: 8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: it.color.withValues(alpha: 0.15),
            child: Icon(it.icon, color: it.color),
          ),
          const SizedBox(height: 16),
          const Spacer(),
          Text(it.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(it.category, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _connected.contains(it.name)
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: buttonPadding),
                    onPressed: () => _confirmDisconnect(it.name),
                    child: const Text('Connected'))
                : FilledButton(
                    style: FilledButton.styleFrom(padding: buttonPadding),
                    onPressed: () => _toggle(it.name),
                    child: const Text('Connect')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final minTileWidth = MediaQuery.textScalerOf(context).scale(130);

    return Scaffold(
      appBar: AppBar(title: const Text('Integrations')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = ((constraints.maxWidth - 20) / (minTileWidth + 12))
              .floor()
              .clamp(1, 4);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            children: [
              for (var i = 0; i < _items.length; i += columns)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        for (var j = i; j < i + columns; j++)
                          Expanded(
                            child: j < _items.length
                                ? _tile(_items[j], scheme)
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
