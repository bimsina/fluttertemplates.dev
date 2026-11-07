import 'dart:async';

import 'package:flutter/material.dart';

const _cannedReply =
    'Great choice. Start with a Scaffold, a monthly summary card, and a '
    'categorized transaction list backed by a simple model.';
const _tokenInterval = Duration(milliseconds: 60);

/// Ticks to wait before the first token, so the typing dots get a moment.
const _thinkingTicks = 10;

/// Simulated model output: splits [reply] into word tokens and emits one per
/// tick. Swap this for your provider's streaming response. Stream.periodic
/// stops its timer when the subscription is cancelled.
Stream<String> _simulatedTokens(String reply) {
  final tokens = RegExp(r'\S+\s*').allMatches(reply).map((m) => m[0]!).toList();
  return Stream<int>.periodic(_tokenInterval, (tick) => tick)
      .skip(_thinkingTicks)
      .take(tokens.length)
      .map((tick) => tokens[tick - _thinkingTicks]);
}

class _Msg {
  final String text;
  final bool fromUser;
  const _Msg(this.text, this.fromUser);
}

class AiChat extends StatefulWidget {
  const AiChat({super.key});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_Msg>[
    const _Msg('Give me three ideas for a weekend project in Flutter.', true),
    const _Msg(
      'Sure! Here are three: 1) A habit tracker with streaks, 2) a Markdown notes app with live preview, and 3) a small budgeting dashboard. Want me to sketch the architecture for one?',
      false,
    ),
    const _Msg('The budgeting dashboard sounds fun.', true),
  ];

  /// The reply so far: null when idle, empty until the first token arrives.
  String? _partialReply;
  StreamSubscription<String>? _replySubscription;

  @override
  void dispose() {
    _replySubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _partialReply != null) return;
    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _partialReply = '';
    });
    _scrollToEnd();
    _replySubscription = _simulatedTokens(_cannedReply).listen((token) {
      setState(() => _partialReply = _partialReply! + token);
      _scrollToEnd();
    }, onDone: _finishReply);
  }

  /// Moves the streamed text into the history.
  void _finishReply() {
    _replySubscription = null;
    setState(() {
      final reply = _partialReply ?? '';
      if (reply.isNotEmpty) _messages.add(_Msg(reply, false));
      _partialReply = null;
    });
  }

  void _stopReply() {
    _replySubscription?.cancel();
    _finishReply();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final partialReply = _partialReply;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 14, child: Icon(Icons.auto_awesome, size: 16)),
            SizedBox(width: 10),
            Text('Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (partialReply != null ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return _Bubble(
                    fromUser: false,
                    child: partialReply!.isEmpty
                        ? const _TypingDots()
                        : Text(
                            partialReply,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                  );
                }
                final m = _messages[i];
                return _Bubble(
                  fromUser: m.fromUser,
                  child: Text(
                    m.text,
                    style: TextStyle(
                      color: m.fromUser
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          Text(
            'Demo: replies are simulated, no model is called',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message Assistant…',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  partialReply == null
                      ? IconButton.filled(
                          tooltip: 'Send message',
                          onPressed: _send,
                          icon: const Icon(Icons.arrow_upward),
                        )
                      : IconButton.filled(
                          tooltip: 'Stop response',
                          onPressed: _stopReply,
                          icon: const Icon(Icons.stop),
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

class _Bubble extends StatelessWidget {
  final bool fromUser;
  final Widget child;
  const _Bubble({required this.fromUser, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: fromUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_c.value + i * 0.2) % 1.0;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(
                  alpha: 0.4 + 0.6 * (1 - (t - 0.5).abs() * 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
