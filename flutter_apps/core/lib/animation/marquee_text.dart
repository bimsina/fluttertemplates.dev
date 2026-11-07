import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  late final Ticker _ticker = createTicker(_tick);
  final _scroll = ScrollController();
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final seconds = (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) return;

    final viewport = _scroll.position.viewportDimension;
    // Content is two equal copies, so this is the width of one copy.
    final copyWidth = (_scroll.position.maxScrollExtent + viewport) / 2;
    if (copyWidth <= viewport) return; // The text fits, nothing to scroll.

    // At one copy's width the view matches offset 0, so wrapping is invisible.
    _scroll.jumpTo((_scroll.offset + widget.velocity * seconds) % copyWidth);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Each copy fills the viewport at least, so the second copy is always
        // ready to take over, and short text sits alone with no duplicate.
        final copy = ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Text(widget.text,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        );
        return ClipRect(
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(children: [copy, copy]),
          ),
        );
      },
    );
  }
}
