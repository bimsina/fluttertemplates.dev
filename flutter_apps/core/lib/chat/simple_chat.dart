import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({required this.text, required this.isMe, required this.timestamp});
}

class ChatService {
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<bool> _typingController =
      StreamController<bool>.broadcast();
  final Random _random = Random();
  final Set<Timer> _pendingReplies = {};

  Stream<Message> get messageStream => _messageController.stream;
  Stream<bool> get typingStream => _typingController.stream;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(text: text, isMe: true, timestamp: DateTime.now());

    _messageController.add(message);
    _simulateResponse(text);
  }

  void _simulateResponse(String originalMessage) {
    // Random delay between 1-3 seconds
    final delay = _random.nextInt(3) + 1;

    late final Timer timer;
    timer = Timer(Duration(seconds: delay), () {
      // Stay in the typing state until the last pending reply lands
      _pendingReplies.remove(timer);
      _typingController.add(_pendingReplies.isNotEmpty);

      final response = Message(
        text: "This is a simulated response to: $originalMessage",
        isMe: false,
        timestamp: DateTime.now(),
      );

      _messageController.add(response);
    });
    _pendingReplies.add(timer);

    // Show typing indicator
    _typingController.add(true);
  }

  void dispose() {
    for (final timer in _pendingReplies) {
      timer.cancel();
    }
    _pendingReplies.clear();
    _messageController.close();
    _typingController.close();
  }
}

class SimpleChat extends StatefulWidget {
  const SimpleChat({super.key});

  @override
  State<SimpleChat> createState() => _SimpleChatState();
}

class _SimpleChatState extends State<SimpleChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<Message> _messages = [];
  bool _isTyping = false;
  late final StreamSubscription<Message> _messageSubscription;
  late final StreamSubscription<bool> _typingSubscription;

  @override
  void initState() {
    super.initState();
    _messageSubscription = _chatService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });

    _typingSubscription = _chatService.typingStream.listen((isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _typingSubscription.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    _chatService.sendMessage(text);
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return Align(
                  alignment: message.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMe
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isMe
                            ? Colors.white
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  tooltip: 'Send message',
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
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
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Widget _buildDot(int index, Color color) {
    final start = index * 0.2;
    final hop = Interval(start, start + 0.4, curve: Curves.easeInOut);
    return Transform.translate(
      offset: Offset(0, -4 * sin(pi * hop.transform(_bounce.value))),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0, color),
          const SizedBox(width: 4),
          _buildDot(1, color),
          const SizedBox(width: 4),
          _buildDot(2, color),
        ],
      ),
    );
  }
}
