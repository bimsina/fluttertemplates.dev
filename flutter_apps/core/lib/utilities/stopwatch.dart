import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  int _milliseconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  final List<int> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        _milliseconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _milliseconds = 0;
      _laps.clear();
      _isRunning = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _addLap() {
    setState(() {
      _laps.insert(0, _milliseconds);
    });
  }

  String get _timeDisplay {
    final minutes = (_milliseconds ~/ 6000).toString().padLeft(2, '0');
    final seconds = ((_milliseconds % 6000) ~/ 100).toString().padLeft(2, '0');
    final ms = (_milliseconds % 100).toString().padLeft(2, '0');
    return '$minutes:$seconds.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (_laps.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _laps.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRunning ? Colors.blue : Colors.grey[400]!,
                        width: 8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _timeDisplay,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'monospace',
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        label: _isRunning ? 'Stop' : 'Start',
                        icon: _isRunning ? Icons.stop : Icons.play_arrow,
                        color: _isRunning ? Colors.red : Colors.blue,
                        onTap: _toggleTimer,
                      ),
                      const SizedBox(width: 24),
                      _buildControlButton(
                        label: 'Lap',
                        icon: Icons.flag,
                        color: Colors.orange,
                        onTap: _isRunning ? _addLap : null,
                      ),
                      const SizedBox(width: 24),
                      _buildControlButton(
                        label: 'Reset',
                        icon: Icons.refresh,
                        color: Colors.grey,
                        onTap: _reset,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_laps.isNotEmpty)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Laps',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_laps.length} laps',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _laps.length,
                        itemBuilder: (context, index) {
                          final lap = _laps[index];
                          final minutes = (lap ~/ 6000).toString().padLeft(
                            2,
                            '0',
                          );
                          final seconds = ((lap % 6000) ~/ 100)
                              .toString()
                              .padLeft(2, '0');
                          final ms = (lap % 100).toString().padLeft(2, '0');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lap ${_laps.length - index}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '$minutes:$seconds.$ms',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: onTap != null ? 1 : 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? color : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
