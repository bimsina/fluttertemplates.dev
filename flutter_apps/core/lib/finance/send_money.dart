import 'package:flutter/material.dart';

const _contacts = [
  {'name': 'Alice', 'avatar': 'A'},
  {'name': 'Bob', 'avatar': 'B'},
  {'name': 'Carol', 'avatar': 'C'},
  {'name': 'David', 'avatar': 'D'},
];

class SendMoney extends StatelessWidget {
  const SendMoney({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Text('\$', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
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
              children: _contacts.map((c) => Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(c['avatar'] as String),
                  ),
                  const SizedBox(height: 8),
                  Text(c['name'] as String, style: Theme.of(context).textTheme.bodySmall),
                ],
              )).toList(),
            ),
            const SizedBox(height: 24),
            Text('Recent', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(3, (i) => ListTile(
              leading: CircleAvatar(child: Text(_contacts[i]['avatar'] as String)),
              title: Text(_contacts[i]['name'] as String),
              subtitle: Text('•••• 4242'),
              trailing: const Icon(Icons.send, color: Colors.green),
            )),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {},
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
