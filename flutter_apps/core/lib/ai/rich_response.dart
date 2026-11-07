import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RichResponse extends StatefulWidget {
  const RichResponse({super.key});

  @override
  State<RichResponse> createState() => _RichResponseState();
}

class _RichResponseState extends State<RichResponse> {
  // True for a thumbs up, false for a thumbs down, null when unrated.
  bool? _rating;

  void _rate(bool good) =>
      setState(() => _rating = _rating == good ? null : good);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Assistant')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                  radius: 16, child: Icon(Icons.auto_awesome, size: 18)),
              const SizedBox(width: 10),
              Text('Assistant',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Fibonacci in Dart',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Here\'s a simple recursive implementation. For large inputs you should memoize or use an iterative approach:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _CodeBlock(
            language: 'dart',
            code: 'int fib(int n) {\n'
                '  if (n < 2) return n;\n'
                '  return fib(n - 1) + fib(n - 2);\n'
                '}',
          ),
          const SizedBox(height: 14),
          _bullet(context, 'Time complexity is O(2ⁿ) for the naïve version.'),
          _bullet(context, 'Use a Map cache to bring it down to O(n).'),
          _bullet(context, 'An iterative loop avoids stack overflow.'),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                  tooltip: 'Good response',
                  isSelected: _rating == true,
                  onPressed: () => _rate(true),
                  icon: const Icon(Icons.thumb_up_outlined),
                  selectedIcon: const Icon(Icons.thumb_up)),
              IconButton(
                  tooltip: 'Bad response',
                  isSelected: _rating == false,
                  onPressed: () => _rate(false),
                  icon: const Icon(Icons.thumb_down_outlined),
                  selectedIcon: const Icon(Icons.thumb_down)),
              IconButton(
                  tooltip: 'Regenerate',
                  onPressed: () => _showDemo(context, 'Regenerate (demo)'), icon: const Icon(Icons.refresh)),
              IconButton(
                  tooltip: 'Share',
                  onPressed: () => _showDemo(context, 'Share (demo)'), icon: const Icon(Icons.share_outlined)),
              Expanded(
                child: Text('Regenerate',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String language;
  final String code;
  const _CodeBlock({required this.language, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A3C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(language,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const Spacer(),
                InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: code)),
                  child: const Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('Copy',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              code,
              style: const TextStyle(
                color: Color(0xFFE6E6F0),
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
