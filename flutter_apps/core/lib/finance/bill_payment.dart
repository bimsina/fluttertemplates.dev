import 'package:flutter/material.dart';

const _bills = [
  {'name': 'Electric', 'amount': 85, 'due': 'Mar 5', 'paid': false},
  {'name': 'Internet', 'amount': 45, 'due': 'Mar 8', 'paid': true},
  {'name': 'Water', 'amount': 62, 'due': 'Mar 10', 'paid': false},
  {'name': 'Phone', 'amount': 120, 'due': 'Mar 15', 'paid': false},
];

class BillPayment extends StatefulWidget {
  /// Called with a bill's name when it's paid, once per bill for 'Pay All'.
  final ValueChanged<String>? onPay;

  const BillPayment({super.key, this.onPay});

  @override
  State<BillPayment> createState() => _BillPaymentState();
}

class _BillPaymentState extends State<BillPayment> {
  final _paid = {
    for (final b in _bills)
      if (b['paid'] as bool) b['name'] as String,
  };

  bool _isPaid(Map<String, Object> bill) => _paid.contains(bill['name']);

  void _pay(List<Map<String, Object>> bills) {
    final names = bills.map((b) => b['name'] as String).toList();
    setState(() => _paid.addAll(names));
    final onPay = widget.onPay;
    if (onPay != null) names.forEach(onPay);
    final amount = bills.fold<int>(0, (sum, b) => sum + (b['amount'] as int));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Paid \$$amount (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    final unpaid = _bills.where((b) => !_isPaid(b)).toList();
    final totalDue = unpaid.fold<int>(
      0,
      (sum, b) => sum + (b['amount'] as int),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              // Wrap drops the button to its own line when text is large.
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Due This Month',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$$totalDue',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: unpaid.isEmpty ? null : () => _pay(unpaid),
                    child: const Text('Pay All'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._bills.map(
            (b) => Card(
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long),
                ),
                // A full-width Wrap, not `trailing`, so the amount and button
                // move under the name when text is large.
                title: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b['name'] as String),
                          Text(
                            'Due ${b['due']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${b['amount']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          if (_isPaid(b))
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            )
                          else
                            FilledButton.tonal(
                              onPressed: () => _pay([b]),
                              child: const Text('Pay'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
