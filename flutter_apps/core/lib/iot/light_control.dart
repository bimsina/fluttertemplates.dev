import 'package:flutter/material.dart';

class LightControl extends StatefulWidget {
  const LightControl({super.key});

  @override
  State<LightControl> createState() => _LightControlState();
}

class _LightControlState extends State<LightControl> {
  bool _on = true;
  double _brightness = 0.75;
  int _colorIndex = 2;

  static const _colors = [
    Color(0xFFFFF3E0),
    Color(0xFFFFE0B2),
    Color(0xFFFFCC80),
    Color(0xFF90CAF9),
    Color(0xFFCE93D8),
    Color(0xFFA5D6A7),
    Color(0xFFEF9A9A),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glow = _colors[_colorIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bedroom Light'),
        actions: [Switch(value: _on, onChanged: (v) => setState(() => _on = v))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _on
                    ? glow.withValues(alpha: _brightness)
                    : scheme.surfaceContainerHighest,
                boxShadow: _on
                    ? [
                        BoxShadow(
                            color: glow.withValues(alpha: _brightness * 0.8),
                            blurRadius: 60,
                            spreadRadius: 10),
                      ]
                    : null,
              ),
              child: Icon(Icons.lightbulb,
                  size: 72,
                  color: _on ? Colors.white : scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const Icon(Icons.brightness_low),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    onChanged:
                        _on ? (v) => setState(() => _brightness = v) : null,
                  ),
                ),
                const Icon(Icons.brightness_high),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (var i = 0; i < _colors.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorIndex == i
                              ? scheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
