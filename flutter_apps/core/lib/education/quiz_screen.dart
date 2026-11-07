import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  /// Called with the chosen option's index, or null when skipped. Without it
  /// the demo shows a SnackBar.
  final ValueChanged<int?>? onAnswer;

  const QuizScreen({super.key, this.onAnswer});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var _selected = -1;
  final _currentQuestion = 1;
  final _totalQuestions = 5;

  void _answer(int? choice) {
    final onAnswer = widget.onAnswer;
    if (onAnswer != null) {
      onAnswer(choice);
      return;
    }
    final message = choice == null ? 'Question skipped' : 'Answer submitted';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$message (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question $_currentQuestion of $_totalQuestions'),
        leading: IconButton(
          tooltip: 'Close quiz',
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
                TextButton(
                  onPressed: () => _answer(null),
                  child: const Text('Skip'),
                ),
                FilledButton(
                  onPressed: _selected >= 0 ? () => _answer(_selected) : null,
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
