import 'package:flutter/material.dart';

class AudioMessagePlayer extends StatefulWidget {
  const AudioMessagePlayer({super.key});

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  bool _isPlaying = false;
  double _progress = 0.3;

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Sarah',
      'avatar': 'S',
      'audioDuration': '0:15',
      'isMe': false,
      'timestamp': '2:30 PM',
    },
    {
      'sender': 'You',
      'avatar': 'Y',
      'audioDuration': '0:23',
      'isMe': true,
      'timestamp': '2:32 PM',
    },
    {
      'sender': 'Mike',
      'avatar': 'M',
      'audioDuration': '0:45',
      'isMe': false,
      'timestamp': '2:35 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Messages'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildAudioMessage(
            context,
            sender: message['sender'],
            avatar: message['avatar'],
            audioDuration: message['audioDuration'],
            isMe: message['isMe'],
            timestamp: message['timestamp'],
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildAudioMessage(
    BuildContext context, {
    required String sender,
    required String avatar,
    required String audioDuration,
    required bool isMe,
    required String timestamp,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[400],
              child: Text(avatar, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? (isDark ? Colors.blue[700] : Colors.blue[500])
                  : (isDark ? Colors.grey[800] : Colors.grey[200]),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.3)
                              : (isDark ? Colors.white24 : Colors.blue[100]),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: isMe ? Colors.white : Colors.blue[700],
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: _progress,
                              onChanged: (value) {
                                setState(() => _progress = value);
                              },
                              activeColor: isMe
                                  ? Colors.white
                                  : Colors.blue[700],
                              inactiveColor: isMe
                                  ? Colors.white30
                                  : Colors.blue[200],
                            ),
                          ),
                          Text(
                            audioDuration,
                            style: TextStyle(
                              fontSize: 11,
                              color: isMe
                                  ? Colors.white70
                                  : (isDark
                                        ? Colors.white54
                                        : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.purple[400],
              child: Text(avatar, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
}
