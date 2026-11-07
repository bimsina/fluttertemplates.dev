import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _contacts = [
  {'name': 'Alice', 'avatar': 'A'},
  {'name': 'Bob', 'avatar': 'B'},
  {'name': 'Carol', 'avatar': 'C'},
  {'name': 'David', 'avatar': 'D'},
];

class SendMoney extends StatefulWidget {
  /// Called with the recipient and amount once both are valid. Without it the
  /// demo shows a SnackBar.
  final void Function(String recipient, double amount)? onSend;

  const SendMoney({super.key, this.onSend});

  @override
  State<SendMoney> createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  final _amountController = TextEditingController();
  String? _recipient;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _select(String name) => setState(() {
    _recipient = name;
    _error = null;
  });

  void _send() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final recipient = _recipient;
    final error = amount <= 0
        ? 'Enter an amount'
        : recipient == null
        ? 'Choose who to send to'
        : null;
    setState(() => _error = error);
    if (error != null) return;

    final onSend = widget.onSend;
    if (onSend != null) {
      onSend(recipient!, amount);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Sent \$${amount.toStringAsFixed(2)} to $recipient (demo)',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '\$',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Send to', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _contacts.map((c) {
                final name = c['name'] as String;
                final selected = name == _recipient;
                return Semantics(
                  selected: selected,
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _select(name),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: selected ? scheme.primary : null,
                            foregroundColor: selected ? scheme.onPrimary : null,
                            child: Text(c['avatar'] as String),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Recent', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (i) => ListTile(
                leading: CircleAvatar(
                  child: Text(_contacts[i]['avatar'] as String),
                ),
                title: Text(_contacts[i]['name'] as String),
                subtitle: Text('•••• 4242'),
                trailing: const Icon(Icons.send, color: Colors.green),
                selected: _contacts[i]['name'] == _recipient,
                onTap: () => _select(_contacts[i]['name'] as String),
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: _send,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Send Money'),
            ),
          ],
        ),
      ),
    );
  }
}
