/// Money and date formatting without a dependency on `intl`.
///
/// Money is always an `int` number of cents. Swap these helpers for
/// `NumberFormat.currency` and `DateFormat` if you need real localization.
library;

const String currencySymbol = r'$';

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdayNames = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// Formats [cents] as `$1,234.56`. With [signed], positive values get a `+`.
String formatCents(int cents, {bool signed = false, bool decimals = true}) {
  final absolute = cents.abs();
  final whole = groupThousands((absolute ~/ 100).toString());
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final sign = cents < 0 ? '-' : (signed && cents > 0 ? '+' : '');
  return '$sign$currencySymbol$whole${decimals ? '.$fraction' : ''}';
}

/// Inserts thousands separators into a string of digits.
String groupThousands(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String monthShort(DateTime date) => _monthNames[date.month - 1].substring(0, 3);

String monthLong(DateTime date) => _monthNames[date.month - 1];

/// `Today`, `Yesterday`, or `Mon, 12 Oct`, with the year when it differs.
String formatDayLabel(DateTime date, DateTime now) {
  // UTC dates, so a daylight saving change can't make a day 23 hours long.
  final daysAgo = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime.utc(date.year, date.month, date.day)).inDays;
  if (daysAgo == 0) return 'Today';
  if (daysAgo == 1) return 'Yesterday';
  final year = date.year == now.year ? '' : ' ${date.year}';
  return '${_weekdayNames[date.weekday - 1]}, ${date.day} '
      '${monthShort(date)}$year';
}

/// `12 Oct 2026, 14:05`.
String formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${monthShort(date)} ${date.year}, $hour:$minute';
}
