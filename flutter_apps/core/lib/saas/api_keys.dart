import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _Key {
  final String name;
  final String prefix;
  final String created;
  bool revealed = false;
  _Key(this.name, this.prefix, this.created);
}

class ApiKeys extends StatefulWidget {
  const ApiKeys({super.key});

  @override
  State<ApiKeys> createState() => _ApiKeysState();
}

class _ApiKeysState extends State<ApiKeys> {
  final _keys = [
    _Key('Production', 'sk_live_9f2a', 'Jan 12, 2026'),
    _Key('Staging', 'sk_test_4b71', 'Mar 3, 2026'),
    _Key('CI pipeline', 'sk_ci_0c58', 'May 21, 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('API Keys')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Create key'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _keys.length,
        itemBuilder: (context, i) {
          final k = _keys[i];
          final masked = k.revealed
              ? '${k.prefix}_a1b2c3d4e5f6g7h8'
              : '${k.prefix}${'•' * 16}';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(k.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      Text('Created ${k.created}',
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(masked,
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13)),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              setState(() => k.revealed = !k.revealed),
                          icon: Icon(k.revealed
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Clipboard.setData(
                              ClipboardData(text: masked)),
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          foregroundColor: scheme.error),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Revoke'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
