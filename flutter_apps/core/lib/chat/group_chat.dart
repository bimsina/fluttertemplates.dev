import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class User {
  final String id;
  final String name;
  final Color color;

  User({required this.id, required this.name, required this.color});
}

class Message {
  final String text;
  final User sender;
  final DateTime timestamp;

  Message({required this.text, required this.sender, required this.timestamp});
}

class ChatService {
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<Set<User>> _typingController =
      StreamController<Set<User>>.broadcast();
  final Random _random = Random();

  // Simulated users
  final List<User> users = [
    User(id: '1', name: 'You', color: Colors.blue),
    User(id: '2', name: 'Alice', color: Colors.purple),
    User(id: '3', name: 'Bob', color: Colors.green),
    User(id: '4', name: 'Charlie', color: Colors.orange),
  ];

  User get currentUser => users[0];
  Stream<Message> get messageStream => _messageController.stream;
  Stream<Set<User>> get typingStream => _typingController.stream;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(
      text: text,
      sender: currentUser,
      timestamp: DateTime.now(),
    );

    _messageController.add(message);
    _simulateResponses(text);
  }

  void _simulateResponses(String originalMessage) {
    // Random number of responses (1-3)
    final numResponses = _random.nextInt(3) + 1;
    final typingUsers = <User>{};

    for (var i = 0; i < numResponses; i++) {
      // Random delay between 1-3 seconds
      final delay = _random.nextInt(3) + 1;

      // Pick a random user (excluding current user)
      final randomUser = users[_random.nextInt(users.length - 1) + 1];
      typingUsers.add(randomUser);

      // Show typing indicator
      _typingController.add(typingUsers);

      Future.delayed(Duration(seconds: delay), () {
        // Remove user from typing
        typingUsers.remove(randomUser);
        _typingController.add(typingUsers);

        final response = Message(
          text: "${randomUser.name} responds to: $originalMessage",
          sender: randomUser,
          timestamp: DateTime.now(),
        );

        _messageController.add(response);
      });
    }
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
  }
}

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<Message> _messages = [];
  Set<User> _typingUsers = {};

  @override
  void initState() {
    super.initState();
    _chatService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });

    _chatService.typingStream.listen((users) {
      setState(() {
        _typingUsers = users;
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

  Widget _buildAvatar(User user) {
    return CircleAvatar(
      backgroundColor: user.color,
      child: Text(
        user.name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(User user) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 8),
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
      appBar: AppBar(title: const Text('Group Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + _typingUsers.length,
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  final typingUser = _typingUsers.elementAt(
                    index - _messages.length,
                  );
                  return _buildTypingIndicator(typingUser);
                }

                final message = _messages[index];
                final isMe = message.sender.id == _chatService.currentUser.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        _buildAvatar(message.sender),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  bottom: 4,
                                ),
                                child: Text(
                                  message.sender.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        _buildAvatar(message.sender),
                      ],
                    ],
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
