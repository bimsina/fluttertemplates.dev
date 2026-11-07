import 'dart:math';

import 'package:flutter/material.dart';

class _DayForecast {
  final int high;
  final int low;
  final IconData icon;
  const _DayForecast(this.high, this.low, this.icon);
}

const _currentTemp = 72;

/// Sample data for the next 24 hours, starting now. Today's high and low in
/// [_week] match the warmest and coolest of these.
const _hourlyTemps = [
  72, 73, 74, 75, 76, 75, 74, 72, 70, 68, 66, 64, //
  63, 62, 62, 63, 64, 65, 66, 68, 69, 70, 71, 72,
];

const _week = [
  _DayForecast(76, 62, Icons.wb_sunny),
  _DayForecast(74, 64, Icons.wb_cloudy),
  _DayForecast(70, 58, Icons.umbrella),
  _DayForecast(68, 56, Icons.grain),
  _DayForecast(71, 60, Icons.wb_cloudy),
  _DayForecast(75, 65, Icons.wb_sunny),
  _DayForecast(76, 66, Icons.wb_sunny),
];

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats an hour from 0 to 23 as a 12-hour label such as 12AM or 1PM.
String _hourLabel(int hour) {
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour${hour < 12 ? 'AM' : 'PM'}';
}

class WeatherDashboard extends StatelessWidget {
  const WeatherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[600]!, Colors.blue[300]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'San Francisco',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_weekdays[now.weekday - 1]}, '
                          '${_months[now.month - 1]} ${now.day}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _showDemo(context, 'Menu (demo)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '$_currentTemp°F',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const Text(
                'Partly Cloudy',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'H: ${_week.first.high}° L: ${_week.first.low}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hourly Forecast',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _hourlyTemps.length,
                            itemBuilder: (context, index) {
                              final hour = (now.hour + index) % 24;
                              return _buildHourlyItem(
                                context,
                                time: index == 0 ? 'Now' : _hourLabel(hour),
                                temp: '${_hourlyTemps[index]}°',
                                icon: hour >= 6 && hour < 18
                                    ? Icons.wb_sunny
                                    : Icons.nightlight_round,
                                isDark: isDark,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '7-Day Forecast',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (var i = 0; i < _week.length; i++)
                          _buildDayForecast(
                            i == 0
                                ? 'Today'
                                : _weekdays[(now.weekday - 1 + i) % 7],
                            _week[i],
                          ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeatherDetail(
                                Icons.water_drop,
                                'Humidity',
                                '45%',
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildWeatherDetail(
                                Icons.air,
                                'Wind',
                                '12 mph',
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildWeatherDetail(
                                Icons.wb_sunny_outlined,
                                'UV Index',
                                '6',
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyItem(
    BuildContext context, {
    required String time,
    required String temp,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          Icon(icon, color: Colors.orange),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDayForecast(String day, _DayForecast forecast) {
    final weekLow = _week.map((d) => d.low).reduce(min);
    final weekHigh = _week.map((d) => d.high).reduce(max);
    final weekRange = weekHigh - weekLow;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Icon(forecast.icon, color: Colors.orange, size: 20),
          const SizedBox(width: 16),
          // The fill spans this day's low to high within the week's range.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = constraints.maxWidth / weekRange;
                return Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: (forecast.low - weekLow) * scale,
                        width: (forecast.high - forecast.low) * scale,
                        top: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Text('${forecast.low}°'),
          const SizedBox(width: 12),
          Text(
            '${forecast.high}°',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey[600],
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
