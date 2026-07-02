import 'package:flutter/material.dart';

class DeviceControls extends StatefulWidget {
  const DeviceControls({super.key});

  @override
  State<DeviceControls> createState() => _DeviceControlsState();
}

class _DeviceControlsState extends State<DeviceControls> {
  final _toggles = {'Lamp': true, 'Fan': false, 'Plug': true};
  double _brightness = 0.7;
  double _fanSpeed = 0.4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Living Room')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in _toggles.entries)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: SwitchListTile(
                value: entry.value,
                onChanged: (v) => setState(() => _toggles[entry.key] = v),
                secondary: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    entry.key == 'Lamp'
                        ? Icons.lightbulb_outline
                        : entry.key == 'Fan'
                            ? Icons.mode_fan_off
                            : Icons.power,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                title: Text(entry.key),
                subtitle: Text(entry.value ? 'On' : 'Off'),
              ),
            ),
          const SizedBox(height: 12),
          _SliderCard(
            icon: Icons.brightness_6,
            label: 'Brightness',
            value: _brightness,
            display: '${(_brightness * 100).round()}%',
            onChanged: (v) => setState(() => _brightness = v),
          ),
          _SliderCard(
            icon: Icons.air,
            label: 'Fan speed',
            value: _fanSpeed,
            display: '${(_fanSpeed * 100).round()}%',
            onChanged: (v) => setState(() => _fanSpeed = v),
          ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String display;
  final double value;
  final ValueChanged<double> onChanged;
  const _SliderCard({
    required this.icon,
    required this.label,
    required this.display,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(display),
              ],
            ),
            Slider(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
