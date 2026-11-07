import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _Lap {
  final Duration split;
  final Duration total;
  const _Lap(this.split, this.total);
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final _stopwatch = Stopwatch();
  Timer? _timer;
  final List<_Lap> _laps = [];

  bool get _isRunning => _stopwatch.isRunning;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _stopwatch
        ..stop()
        ..reset();
      _laps.clear();
    });
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        // Elapsed time comes from the Stopwatch; this only repaints.
        _timer = Timer.periodic(
          const Duration(milliseconds: 30),
          (_) => setState(() {}),
        );
      }
    });
  }

  void _addLap() {
    final total = _stopwatch.elapsed;
    final previous = _laps.isEmpty ? Duration.zero : _laps.first.total;
    setState(() {
      _laps.insert(0, _Lap(total - previous, total));
    });
  }

  String _format(Duration time) {
    final minutes = time.inMinutes.toString().padLeft(2, '0');
    final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (time.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
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
              tooltip: 'Clear laps',
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
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Controls need about 100px; the dial takes what's left.
                final dial = (constraints.maxHeight - 124).clamp(48.0, 280.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: dial,
                      height: dial,
                      padding: EdgeInsets.all(dial * 0.07),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRunning ? Colors.blue : Colors.grey[400]!,
                          width: 8,
                        ),
                      ),
                      child: FittedBox(
                        child: Text(
                          _format(_stopwatch.elapsed),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                );
              },
            ),
          ),
          if (_laps.isNotEmpty)
            Expanded(
              flex: 2,
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
                                  _format(lap.split),
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
          const SizedBox(height: 4),
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
