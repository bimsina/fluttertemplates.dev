import 'package:flutter/material.dart';

const _rates = [
  {'code': 'EUR', 'name': 'Euro', 'rate': 0.92},
  {'code': 'GBP', 'name': 'British Pound', 'rate': 0.79},
  {'code': 'JPY', 'name': 'Japanese Yen', 'rate': 149.50},
  {'code': 'CAD', 'name': 'Canadian Dollar', 'rate': 1.36},
];

class CurrencyConverter extends StatelessWidget {
  const CurrencyConverter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: 'USD ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: 'EUR',
                      decoration: const InputDecoration(
                        labelText: 'Convert to',
                        border: OutlineInputBorder(),
                      ),
                      items: _rates
                          .map(
                            (r) => DropdownMenuItem(
                              value: r['code'] as String,
                              child: Text('${r['code']} - ${r['name']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Convert'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Live Rates (USD)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._rates.map(
              (r) => Card(
                child: ListTile(
                  leading: Text(
                    r['code'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  title: Text(r['name'] as String),
                  trailing: Text(
                    '1 USD = ${r['rate']} ${r['code']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
