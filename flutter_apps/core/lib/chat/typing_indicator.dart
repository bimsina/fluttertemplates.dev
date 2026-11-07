import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class _Message {
  const _Message(this.author, this.text);

  /// Null means the current user.
  final String? author;
  final String text;
}

const _scripts = {
  'Maya': ['Just pushed the fix.', 'Tests are green on my side.'],
  'Sam': ['Nice, deploying now.', 'I will watch the logs for a bit.'],
};

class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Message>[
    const _Message('Maya', 'Is the release branch cut yet?'),
    const _Message(null, 'Almost, one failing test left.'),
  ];

  /// Everyone currently typing, in the order they started.
  final _typing = <String>[];
  final _timers = <Timer>{};
  var _replyRound = 0;

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _after(Duration delay, VoidCallback action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      action();
    });
    _timers.add(timer);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  /// Replace with your presence channel: `start` on a typing event, and
  /// remove the name on a message or after a few seconds of silence.
  void _simulateTyping(String name, Duration startAfter, Duration typingFor) {
    if (_typing.contains(name)) return;
    _after(startAfter, () {
      setState(() => _typing.add(name));
      _scrollToEnd();
      _after(typingFor, () {
        final lines = _scripts[name]!;
        setState(() {
          _typing.remove(name);
          _messages.add(_Message(name, lines[_replyRound % lines.length]));
        });
        _scrollToEnd();
      });
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(_Message(null, text)));
    _controller.clear();
    _scrollToEnd();
    _replyRound++;
    _simulateTyping(
      'Maya',
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 2400),
    );
    _simulateTyping(
      'Sam',
      const Duration(milliseconds: 1300),
      const Duration(milliseconds: 2800),
    );
  }

  String get _typingLabel => switch (_typing.length) {
        0 => '',
        1 => '${_typing[0]} is typing',
        2 => '${_typing[0]} and ${_typing[1]} are typing',
        _ => 'Several people are typing',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Release crew'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _typing.isEmpty ? '3 members' : _typingLabel,
                key: ValueKey(_typingLabel),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                for (final m in _messages) _Bubble(message: m),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.topLeft,
                  child: _typing.isEmpty
                      ? const SizedBox(width: double.infinity)
                      : Row(
                          children: [
                            for (final name in _typing)
                              Align(
                                widthFactor: 0.75,
                                child: _Initial(name: name),
                              ),
                            const SizedBox(width: 12),
                            const _TypingBubble(),
                          ],
                        ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Send a message to see replies',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Send',
                    onPressed: _send,
                    icon: const Icon(Icons.send),
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

/// Self-contained: drop it into any message list while a peer is typing.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  /// Each dot lifts for the first half of its own offset cycle, then rests.
  double _lift(int dot) {
    final phase = (_wave.value - dot * 0.16) % 1;
    return phase < 0.5 ? math.sin(phase / 0.5 * math.pi) : 0;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Typing',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedBuilder(
          animation: _wave,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var dot = 0; dot < 3; dot++)
                Transform.translate(
                  offset: Offset(0, -4 * _lift(dot)),
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(left: dot == 0 ? 0 : 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        scheme.outline,
                        scheme.onSurface,
                        _lift(dot),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMaya = name == 'Maya';
    return CircleAvatar(
      radius: 14,
      backgroundColor:
          isMaya ? scheme.tertiaryContainer : scheme.secondaryContainer,
      foregroundColor:
          isMaya ? scheme.onTertiaryContainer : scheme.onSecondaryContainer,
      child: Text(name[0], style: const TextStyle(fontSize: 12)),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final author = message.author;
    final mine = author == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[_Initial(name: author), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: mine ? scheme.primary : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mine ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
          ),
          if (!mine) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
