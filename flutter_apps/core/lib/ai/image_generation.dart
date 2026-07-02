import 'package:flutter/material.dart';

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  int _style = 0;
  bool _generating = false;
  bool _hasResults = false;

  final _styles = const ['Realistic', 'Anime', '3D', 'Sketch', 'Neon'];
  final _gradients = const [
    [Color(0xFF6D5BFF), Color(0xFFB06AB3)],
    [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFF396AFC), Color(0xFF2948FF)],
  ];

  void _generate() {
    setState(() => _generating = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _hasResults = true;
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
                : !_hasResults
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
                          for (final g in _gradients)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: g,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.download,
                                      color: Colors.white70),
                                ),
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
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'A calm mountain lake at sunrise…',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                          onPressed: _generate, child: const Text('Generate')),
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
