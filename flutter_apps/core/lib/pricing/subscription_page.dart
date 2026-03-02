import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  var _interval = 'monthly';
  var _selectedPlan = 'pro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ButtonSegment(value: 'yearly', label: Text('Yearly')),
              ],
              selected: {_interval},
              onSelectionChanged: (s) => setState(() => _interval = s.first),
            ),
            const SizedBox(height: 24),
            RadioGroup<String>(
              groupValue: _selectedPlan,
              onChanged: (v) => setState(() => _selectedPlan = v ?? 'pro'),
              child: Column(
                children: [
                  Card(
                    child: RadioListTile<String>(
                      value: 'pro',
                      secondary: const Icon(Icons.star),
                      title: const Text('Pro Plan'),
                      subtitle: Text(_interval == 'yearly' ? '\$190/year (save 17%)' : '\$19/month'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: RadioListTile<String>(
                      value: 'ent',
                      secondary: const Icon(Icons.business),
                      title: const Text('Enterprise'),
                      subtitle: Text(_interval == 'yearly' ? '\$990/year' : '\$99/month'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
