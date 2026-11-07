import 'dart:async';

import 'package:flutter/material.dart';

class _City {
  final String name;
  final String country;
  final String timezone;

  /// Fixed offset from UTC in minutes. Daylight saving is not modelled.
  final int offsetMinutes;
  const _City(this.name, this.country, this.timezone, this.offsetMinutes);
}

const _cities = [
  _City('New York', 'USA', 'EST', -5 * 60),
  _City('London', 'UK', 'GMT', 0),
  _City('Paris', 'France', 'CET', 1 * 60),
  _City('Dubai', 'UAE', 'GST', 4 * 60),
  _City('Mumbai', 'India', 'IST', 5 * 60 + 30),
  _City('Tokyo', 'Japan', 'JST', 9 * 60),
  _City('Sydney', 'Australia', 'AEDT', 11 * 60),
];

class WorldClock extends StatefulWidget {
  /// The time source, replaceable in tests.
  final DateTime Function() now;

  const WorldClock({super.key, this.now = DateTime.now});

  @override
  State<WorldClock> createState() => _WorldClockState();
}

class _WorldClockState extends State<WorldClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Fires at the start of the next minute, then reschedules itself.
  void _scheduleTick() {
    final now = widget.now();
    final untilNextMinute =
        const Duration(minutes: 1) -
        Duration(seconds: now.second, milliseconds: now.millisecond);
    _timer = Timer(untilNextMinute, () {
      setState(() {});
      _scheduleTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [IconButton(tooltip: 'Add city', icon: const Icon(Icons.add), onPressed: () => _showDemo(context, 'Add city (demo)'))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cities.length,
        itemBuilder: (context, index) => _buildLocationCard(_cities[index]),
      ),
    );
  }

  Widget _buildLocationCard(_City city) {
    final localTime = widget.now().toUtc().add(
      Duration(minutes: city.offsetMinutes),
    );
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final isDay = hour >= 6 && hour < 18;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDay
              ? [Colors.blue[400]!, Colors.blue[600]!]
              : [Colors.indigo[900]!, Colors.purple[900]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDay ? Icons.wb_sunny : Icons.nightlight_round,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      city.timezone,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  city.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  city.country,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$displayHour:$minute',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'More options',
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onPressed: () => _showDemo(context, 'More options (demo)'),
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
