import 'package:flutter/material.dart';

class Sliders extends StatefulWidget {
  const Sliders({super.key});

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  double _value = 40;
  RangeValues _range = const RangeValues(20, 80);
  double _stepped = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sliders')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            'Value slider',
            '${_value.round()}',
            Slider(
              value: _value,
              max: 100,
              label: '${_value.round()}',
              divisions: 100,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          _card(
            context,
            'Range slider',
            '${_range.start.round()} – ${_range.end.round()}',
            RangeSlider(
              values: _range,
              max: 100,
              divisions: 100,
              labels: RangeLabels(
                  '${_range.start.round()}', '${_range.end.round()}'),
              onChanged: (v) => setState(() => _range = v),
            ),
          ),
          _card(
            context,
            'Stepped slider',
            'Level ${_stepped.round()}',
            Slider(
              value: _stepped,
              max: 5,
              divisions: 5,
              label: 'Level ${_stepped.round()}',
              onChanged: (v) => setState(() => _stepped = v),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sliders let people select a value or range along a track. Add divisions for stepped selection.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String label, String value, Widget slider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(value,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            slider,
          ],
        ),
      ),
    );
  }
}
