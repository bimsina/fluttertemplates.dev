import 'package:flutter/material.dart';

const _faqs = [
  {'q': 'How do I get started?', 'a': 'Download the app and create an account to begin.'},
  {'q': 'What payment methods do you accept?', 'a': 'We accept all major credit cards and PayPal.'},
  {'q': 'Can I cancel anytime?', 'a': 'Yes, you can cancel your subscription at any time.'},
];

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _faqs.map((faq) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(faq['q'] as String),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(faq['a'] as String),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
