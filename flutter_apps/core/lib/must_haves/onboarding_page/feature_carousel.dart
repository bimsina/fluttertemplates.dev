import 'dart:async';
import 'package:flutter/material.dart';

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _Feature(this.icon, this.title, this.body, this.color);
}

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final _controller = PageController(viewportFraction: 0.86);
  int _page = 0;
  Timer? _timer;

  static const _features = [
    _Feature(Icons.flash_on, 'Lightning fast',
        'Everything loads instantly, even offline.', Color(0xFFFF8A65)),
    _Feature(Icons.lock_outline, 'Private by default',
        'Your data is encrypted end to end.', Color(0xFF4DB6AC)),
    _Feature(Icons.sync, 'Sync everywhere',
        'Pick up right where you left off on any device.', Color(0xFF7986CB)),
    _Feature(Icons.auto_awesome, 'Smart suggestions',
        'Helpful nudges powered by on-device AI.', Color(0xFFBA68C8)),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _features.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('Why you\'ll love it',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _features.length,
                itemBuilder: (context, i) {
                  final f = _features[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: f.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: 44,
                            backgroundColor: f.color,
                            child: Icon(f.icon,
                                size: 44, color: Colors.white)),
                        const SizedBox(height: 28),
                        Text(f.title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(f.body,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_features.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                    onPressed: () {}, child: const Text('Continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
