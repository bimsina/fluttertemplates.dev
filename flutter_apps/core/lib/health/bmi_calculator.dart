import 'package:flutter/material.dart';

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '70');
  double? _bmi;
  String? _category;

  void _calculate() {
    final h = double.tryParse(_heightController.text) ?? 0;
    final w = double.tryParse(_weightController.text) ?? 0;
    if (h > 0 && w > 0) {
      final bmi = w / ((h / 100) * (h / 100));
      String cat;
      if (bmi < 18.5) {
        cat = 'Underweight';
      } else {
        switch (bmi) {
          case < 25:
            cat = 'Normal';
          case < 30:
            cat = 'Overweight';
          default:
            cat = 'Obese';
        }
      }
      setState(() {
        _bmi = bmi;
        _category = cat;
      });
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _calculate,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Calculate BMI'),
            ),
            if (_bmi != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        _category!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
