import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  const MarqueeText({super.key});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Marquee Text')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Breaking news banner',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: double.infinity,
                  alignment: Alignment.center,
                  color: scheme.error,
                  child: Text('LIVE',
                      style: TextStyle(
                          color: scheme.onError,
                          fontWeight: FontWeight.bold)),
                ),
                const Expanded(
                  child: _Marquee(
                    text:
                        'Markets rally as tech stocks surge  •  Flutter 4 announced at I/O  •  New template pack drops Friday  •  ',
                    velocity: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Now playing',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.music_note,
                      color: scheme.onPrimaryContainer)),
              const SizedBox(width: 12),
              const Expanded(
                child: _Marquee(
                  text:
                      'The Very Long Song Title That Definitely Does Not Fit — Featured Artist  ',
                  velocity: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Marquee extends StatefulWidget {
  final String text;
  final double velocity; // pixels per second
  const _Marquee({required this.text, required this.velocity});

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _c.addListener(_tick);
  }

  void _tick() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    var next = _scroll.offset + widget.velocity / 60;
    if (next >= max) next = 0;
    _scroll.jumpTo(next);
  }

  @override
  void dispose() {
    _c.removeListener(_tick);
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doubled = widget.text + widget.text;
    return ClipRect(
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(doubled,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
