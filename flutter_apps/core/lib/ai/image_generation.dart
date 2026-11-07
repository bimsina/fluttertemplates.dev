import 'dart:math';

import 'package:flutter/material.dart';

class _GeneratedImage {
  final List<Color> colors;
  final String caption;
  const _GeneratedImage(this.colors, this.caption);
}

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  final _controller = TextEditingController();
  int _style = 0;
  bool _generating = false;
  List<_GeneratedImage> _results = const [];

  final _styles = const ['Realistic', 'Anime', '3D', 'Sketch', 'Neon'];
  // One base gradient per entry in _styles.
  final _palettes = const [
    [Color(0xFF3A6073), Color(0xFF16222A)],
    [Color(0xFFD6459E), Color(0xFF3813C2)],
    [Color(0xFF11806A), Color(0xFF1B4F72)],
    [Color(0xFF6B6F7B), Color(0xFF34373F)],
    [Color(0xFFD400A5), Color(0xFF333399)],
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The style picks the palette and the prompt seeds the hue of each variant,
  // so changing either one changes the four tiles.
  List<_GeneratedImage> _render(String prompt, int style) {
    final random = Random(Object.hash(prompt.toLowerCase(), style));
    return List.generate(4, (_) {
      final shift = random.nextDouble() * 80 - 40;
      return _GeneratedImage([
        for (final color in _palettes[style]) _shiftHue(color, shift),
      ], '${_styles[style]} · $prompt');
    });
  }

  Color _shiftHue(Color color, double degrees) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + degrees) % 360).toColor();
  }

  void _generate() {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _generating) return;
    final style = _style;
    setState(() => _generating = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _results = _render(prompt, style);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Image Generator')),
      body: Column(
        children: [
          Expanded(
            child: _generating
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('Describe an image to generate',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          for (final image in _results)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: image.colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      image.caption,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const Icon(Icons.download,
                                      color: Colors.white70),
                                ],
                              ),
                            ),
                        ],
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _styles.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => ChoiceChip(
                        label: Text(_styles[i]),
                        selected: _style == i,
                        onSelected: (_) => setState(() => _style = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _generate(),
                          decoration: const InputDecoration(
                            hintText: 'A calm mountain lake at sunrise…',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                          onPressed:
                              _controller.text.trim().isEmpty || _generating
                                  ? null
                                  : _generate,
                          child: const Text('Generate')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
