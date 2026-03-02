import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var _selected = -1;
  final _currentQuestion = 1;
  final _totalQuestions = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question $_currentQuestion of $_totalQuestions'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: _currentQuestion / _totalQuestions),
            const SizedBox(height: 24),
            Text(
              'What is a Widget in Flutter?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            RadioGroup<int>(
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v ?? -1),
              child: Column(
                children: [
                  'A building block',
                  'A state manager',
                  'A layout engine',
                  'A database',
                ].asMap().entries.map((e) => RadioListTile<int>(
                  value: e.key,
                  title: Text(e.value),
                )).toList(),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () {}, child: const Text('Skip')),
                FilledButton(
                  onPressed: _selected >= 0 ? () {} : null,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
