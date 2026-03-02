import 'package:flutter/material.dart';

class WorldClock extends StatelessWidget {
  const WorldClock({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final locations = [
      {
        'city': 'New York',
        'country': 'USA',
        'timezone': 'EST',
        'offset': -5,
        'isDay': false,
      },
      {
        'city': 'London',
        'country': 'UK',
        'timezone': 'GMT',
        'offset': 0,
        'isDay': true,
      },
      {
        'city': 'Paris',
        'country': 'France',
        'timezone': 'CET',
        'offset': 1,
        'isDay': true,
      },
      {
        'city': 'Dubai',
        'country': 'UAE',
        'timezone': 'GST',
        'offset': 4,
        'isDay': true,
      },
      {
        'city': 'Tokyo',
        'country': 'Japan',
        'timezone': 'JST',
        'offset': 9,
        'isDay': true,
      },
      {
        'city': 'Sydney',
        'country': 'Australia',
        'timezone': 'AEDT',
        'offset': 11,
        'isDay': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return _buildLocationCard(context, location, isDark);
        },
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    Map<String, dynamic> location,
    bool isDark,
  ) {
    final now = DateTime.now().toUtc();
    final offset = Duration(hours: location['offset'] as int);
    final localTime = now.add(offset);
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
                      location['timezone'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  location['city'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location['country'],
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
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
