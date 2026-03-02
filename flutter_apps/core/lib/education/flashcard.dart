import 'package:flutter/material.dart';

class Flashcard extends StatefulWidget {
  const Flashcard({super.key});

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  var _showBack = false;
  var _index = 0;
  final _cards = [
    {'front': 'What is Flutter?', 'back': 'A UI toolkit for building natively compiled applications.'},
    {'front': 'What is a Widget?', 'back': 'The basic building block of Flutter UI.'},
  ];

  @override
  Widget build(BuildContext context) {
    final card = _cards[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${_index + 1} of ${_cards.length}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _showBack = !_showBack),
              child: Container(
                width: 320,
                height: 200,
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _showBack
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _showBack ? (card['back'] as String) : (card['front'] as String),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
            Text('Tap to flip', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _index > 0 ? () => setState(() { _index--; _showBack = false; }) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: _index < _cards.length - 1
                      ? () => setState(() { _index++; _showBack = false; })
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
