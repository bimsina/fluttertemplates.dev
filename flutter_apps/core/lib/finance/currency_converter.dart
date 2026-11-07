import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _rates = [
  {'code': 'EUR', 'name': 'Euro', 'rate': 0.92},
  {'code': 'GBP', 'name': 'British Pound', 'rate': 0.79},
  {'code': 'JPY', 'name': 'Japanese Yen', 'rate': 149.50},
  {'code': 'CAD', 'name': 'Canadian Dollar', 'rate': 1.36},
];

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final _amountController = TextEditingController();
  var _code = 'EUR';
  String? _error;
  String? _result;

  void _convert() {
    final amount = double.tryParse(_amountController.text.trim());
    setState(() {
      if (amount == null || amount <= 0) {
        _error = 'Enter an amount above 0';
        _result = null;
        return;
      }
      final rate = _rates.firstWhere((r) => r['code'] == _code)['rate'] as double;
      _error = null;
      _result =
          '${amount.toStringAsFixed(2)} USD = '
          '${(amount * rate).toStringAsFixed(2)} $_code';
    });
  }

  // A shown result would be stale after either input changes.
  void _clearResult() {
    setState(() {
      _error = null;
      _result = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => _clearResult(),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: 'USD ',
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _code,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Convert to',
                        border: OutlineInputBorder(),
                      ),
                      items: _rates
                          .map(
                            (r) => DropdownMenuItem(
                              value: r['code'] as String,
                              child: Text(
                                '${r['code']} - ${r['name']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        _code = v ?? _code;
                        _clearResult();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _convert,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Convert'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text(
                _result!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Sample Rates (USD)',
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
                  subtitle: Text('1 USD = ${r['rate']} ${r['code']}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
