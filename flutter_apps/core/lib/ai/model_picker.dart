import 'package:flutter/material.dart';

class _Model {
  final String name;
  final String desc;
  final IconData icon;
  const _Model(this.name, this.desc, this.icon);
}

class ModelPicker extends StatefulWidget {
  const ModelPicker({super.key});

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  int _selected = 0;
  double _temperature = 0.7;
  double _length = 0.5;

  final _models = const [
    _Model('GPT-4o', 'Most capable, best for complex tasks', Icons.auto_awesome),
    _Model('GPT-4o mini', 'Fast and affordable', Icons.bolt),
    _Model('Claude Opus', 'Strong reasoning and long context', Icons.psychology),
    _Model('Local model', 'Runs on device, private', Icons.memory),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Model settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Model',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          for (var i = 0; i < _models.length; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: _selected == i ? scheme.primaryContainer : null,
              child: ListTile(
                onTap: () => setState(() => _selected = i),
                leading: Icon(_models[i].icon),
                title: Text(_models[i].name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_models[i].desc),
                trailing: _selected == i
                    ? Icon(Icons.check_circle, color: scheme.primary)
                    : Icon(Icons.circle_outlined, color: scheme.outline),
              ),
            ),
          const SizedBox(height: 20),
          _SliderTile(
            label: 'Temperature',
            value: _temperature,
            display: _temperature.toStringAsFixed(1),
            onChanged: (v) => setState(() => _temperature = v),
          ),
          _SliderTile(
            label: 'Response length',
            value: _length,
            display: _length < 0.34
                ? 'Short'
                : _length < 0.67
                    ? 'Medium'
                    : 'Long',
            onChanged: (v) => setState(() => _length = v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final String display;
  final double value;
  final ValueChanged<double> onChanged;
  const _SliderTile({
    required this.label,
    required this.display,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(display,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        Slider(value: value, onChanged: onChanged),
      ],
    );
  }
}
