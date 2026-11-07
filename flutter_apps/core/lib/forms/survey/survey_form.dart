import 'package:flutter/material.dart';

class SurveyForm extends StatefulWidget {
  /// Called with the answers once question 1 is answered. Without it the demo
  /// shows a SnackBar.
  final void Function(String choice, List<String> options, int rating)? onSubmit;

  const SurveyForm({super.key, this.onSubmit});

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  var _q1 = '';
  final _q2 = <bool>[false, false, false];
  var _q3 = 3;
  var _q1Missing = false;

  static const _q2Options = ['Option 1', 'Option 2', 'Option 3'];

  void _submit() {
    setState(() => _q1Missing = _q1.isEmpty);
    if (_q1.isEmpty) return;

    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      final options = [
        for (var i = 0; i < _q2Options.length; i++)
          if (_q2[i]) _q2Options[i],
      ];
      onSubmit(_q1, options, _q3);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Survey submitted (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          LinearProgressIndicator(value: 0.6),
          const SizedBox(height: 24),
          Text(
            'Question 1: Single choice',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RadioGroup<String>(
            groupValue: _q1,
            onChanged: (v) => setState(() {
              _q1 = v ?? '';
              _q1Missing = false;
            }),
            child: Column(
              children: ['A', 'B', 'C']
                  .map((o) => RadioListTile<String>(
                        value: o,
                        title: Text(o),
                      ))
                  .toList(),
            ),
          ),
          if (_q1Missing)
            Text(
              'Choose an answer',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 24),
          Text(
            'Question 2: Multiple choice',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ..._q2Options.asMap().entries.map(
                (e) => CheckboxListTile(
                  title: Text(e.value),
                  value: _q2[e.key],
                  onChanged: (v) => setState(() => _q2[e.key] = v ?? false),
                ),
              ),
          const SizedBox(height: 24),
          Text(
            'Question 3: Likert scale (1-5)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _q3.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$_q3',
            onChanged: (v) => setState(() => _q3 = v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('1'), Text('$_q3'), Text('5')],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submit,
            child: const Text('Submit Survey'),
          ),
        ],
      ),
    );
  }
}
