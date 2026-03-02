import 'package:flutter/material.dart';

class VoiceSearch extends StatefulWidget {
  const VoiceSearch({super.key});

  @override
  State<VoiceSearch> createState() => _VoiceSearchState();
}

class _VoiceSearchState extends State<VoiceSearch>
    with SingleTickerProviderStateMixin {
  var _listening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Search')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _listening = !_listening),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _listening
                      ? 1.0 + _pulseController.value * 0.2
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _listening
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 48,
                        color: _listening ? Colors.red : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _listening ? 'Listening...' : 'Tap to start',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_listening)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Say your search query',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
