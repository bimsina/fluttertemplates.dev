import 'package:flutter/material.dart';

const _cards = [
  {'title': 'Card 1', 'color': Colors.blue},
  {'title': 'Card 2', 'color': Colors.green},
  {'title': 'Card 3', 'color': Colors.orange},
  {'title': 'Card 4', 'color': Colors.purple},
  {'title': 'Card 5', 'color': Colors.teal},
];

class HorizontalGallery extends StatefulWidget {
  const HorizontalGallery({super.key});

  @override
  State<HorizontalGallery> createState() => _HorizontalGalleryState();
}

class _HorizontalGalleryState extends State<HorizontalGallery> {
  final _controller = PageController(viewportFraction: 0.85);
  var _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _currentPage = _controller.page ?? 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horizontal Gallery')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                final diff = (index - _currentPage).abs();
                final scale = (1.0 - (diff * 0.15)).clamp(0.85, 1.0);
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: scale),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: child,
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    color: (card['color'] as Color).withValues(alpha: 0.3),
                    child: Center(
                      child: Text(
                        card['title'] as String,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cards.length, (i) {
              final active = (i - _currentPage).abs() < 0.5;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
