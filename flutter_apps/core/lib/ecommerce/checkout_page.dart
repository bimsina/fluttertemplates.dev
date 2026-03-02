import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  var _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () =>
            setState(() => _step = (_step + 1).clamp(0, 2)),
        onStepCancel: () =>
            setState(() => _step = (_step - 1).clamp(0, 2)),
        steps: [
          Step(
            title: const Text('Shipping'),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Payment'),
            content: TextField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Step(
            title: const Text('Summary'),
            content: const Text('Order total: \$75.98'),
          ),
        ],
      ),
    );
  }
}
