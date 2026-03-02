import 'package:flutter/material.dart';

class PostComposer extends StatefulWidget {
  const PostComposer({super.key});

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _controller = TextEditingController();
  var _hasImage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          FilledButton(
            onPressed: () {},
            child: const Text('Post'),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Text('U')),
            title: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () => setState(() => _hasImage = !_hasImage),
              ),
              Text(
                '${_controller.text.length}/500',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (_hasImage)
            Container(
              margin: const EdgeInsets.all(16),
              height: 150,
              color: Colors.grey.withValues(alpha: 0.3),
              child: const Center(child: Icon(Icons.image, size: 48)),
            ),
        ],
      ),
    );
  }
}
