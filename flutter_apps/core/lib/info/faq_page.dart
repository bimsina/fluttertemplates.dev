import 'package:flutter/material.dart';

const _faqs = [
  {'q': 'How do I get started?', 'a': 'Download the app and create an account to begin.'},
  {'q': 'What payment methods do you accept?', 'a': 'We accept all major credit cards and PayPal.'},
  {'q': 'Can I cancel anytime?', 'a': 'Yes, you can cancel your subscription at any time.'},
];

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  var _expanded = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _faqs.asMap().entries.map((e) {
          final i = e.key;
          final faq = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(faq['q'] as String),
              initiallyExpanded: _expanded == i,
              onExpansionChanged: (v) => setState(() => _expanded = v ? i : -1),
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
