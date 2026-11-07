const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// 2:05 PM
String formatClock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}

/// Today, Yesterday, Tuesday, Mar 4, or Mar 4, 2024.
String formatDay(DateTime time, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final age = today.difference(_dateOnly(time)).inHours / 24;
  if (age < 1) return 'Today';
  if (age < 2) return 'Yesterday';
  if (age < 7) return _weekdays[time.weekday - 1];
  final date = '${_months[time.month - 1]} ${time.day}';
  return time.year == today.year ? date : '$date, ${time.year}';
}

/// Short form for the conversation list: the time today, the day otherwise.
String formatListTime(DateTime time, {DateTime? now}) {
  final day = formatDay(time, now: now);
  if (day == 'Today') return formatClock(time);
  return _weekdays.contains(day) ? day.substring(0, 3) : day;
}

DateTime _dateOnly(DateTime time) => DateTime(time.year, time.month, time.day);
