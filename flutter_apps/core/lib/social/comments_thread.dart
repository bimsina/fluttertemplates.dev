import 'package:flutter/material.dart';

const _sampleComments = [
  {'user': 'Alice', 'text': 'Great post!', 'replies': ['Thanks!']},
  {'user': 'Bob', 'text': 'I agree with this.', 'replies': []},
];

class CommentsThread extends StatefulWidget {
  const CommentsThread({super.key});

  @override
  State<CommentsThread> createState() => _CommentsThreadState();
}

class _CommentsThreadState extends State<CommentsThread> {
  final _controller = TextEditingController();
  final _comments = [..._sampleComments];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add({'user': 'You', 'text': text, 'replies': <String>[]});
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, i) {
                final c = _comments[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text((c['user'] as String)[0]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['user'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(c['text'] as String),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if ((c['replies'] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 40, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (c['replies'] as List)
                                .map((r) => Text('↳ $r'))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Post comment',
                    icon: const Icon(Icons.send),
                    onPressed: _send,
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
