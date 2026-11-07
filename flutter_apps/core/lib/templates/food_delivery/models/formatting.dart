String formatMoney(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final fraction = (abs % 100).toString().padLeft(2, '0');
  return '$sign\$${abs ~/ 100}.$fraction';
}

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

String formatClock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}

String formatDate(DateTime time) =>
    '${_months[time.month - 1]} ${time.day}, ${formatClock(time)}';

String pluralize(int count, String noun) =>
    '$count $noun${count == 1 ? '' : 's'}';
