import 'dart:async';

import 'package:flutter/material.dart';

class VoiceSearch extends StatefulWidget {
  const VoiceSearch({super.key});

  @override
  State<VoiceSearch> createState() => _VoiceSearchState();
}

class _VoiceSearchState extends State<VoiceSearch>
    with SingleTickerProviderStateMixin {
  static const _simulatedWords = ['best', 'coffee', 'shops', 'near', 'me'];

  var _listening = false;
  var _transcript = '';
  Timer? _wordTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // Simulated: start and stop your speech plugin here, and update
  // _transcript from its results instead of the timer.
  void _startListening() {
    var heard = 0;
    setState(() {
      _listening = true;
      _transcript = '';
    });
    _pulseController.repeat(reverse: true);
    _wordTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      heard++;
      setState(() {
        _transcript = _simulatedWords.take(heard).join(' ');
      });
      if (heard == _simulatedWords.length) _stopListening();
    });
  }

  void _stopListening() {
    _wordTimer?.cancel();
    _pulseController
      ..stop()
      ..value = 0;
    setState(() => _listening = false);
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
              onTap: _listening ? _stopListening : _startListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + _pulseController.value * 0.2,
                    child: child,
                  );
                },
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
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _listening ? 'Listening...' : 'Tap to start',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _transcript.isEmpty
                    ? (_listening ? 'Say your search query' : '')
                    : _transcript,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              'Simulated transcript, the microphone is not used',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
