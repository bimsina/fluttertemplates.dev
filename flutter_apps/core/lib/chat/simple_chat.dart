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

    // Show typing indicator
    _typingController.add(true);

    Future.delayed(Duration(seconds: delay), () {
      // Hide typing indicator
      _typingController.add(false);

      final response = Message(
        text: "This is a simulated response to: $originalMessage",
        isMe: false,
        timestamp: DateTime.now(),
      );

      _messageController.add(response);
    });
  }

  void dispose() {
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

  @override
  void initState() {
    super.initState();
    _chatService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });

    _chatService.typingStream.listen((isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    });
  }

  @override
  void dispose() {
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
      if (_scrollController.hasClients) {
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
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Interval(index * 0.2, (index + 1) * 0.2, curve: Curves.easeInOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -2 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
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
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isMe ? Colors.white : Colors.black,
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
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
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
