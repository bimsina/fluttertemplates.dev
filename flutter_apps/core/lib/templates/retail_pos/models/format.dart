/// Money is an [int] count of cents everywhere in this template. Doubles never
/// touch a price, so totals cannot drift. These helpers are the only place
/// where cents become display strings.
library;

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
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// `123456` becomes `$1,234.56`.
String formatMoney(int cents, {String symbol = r'$'}) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final whole = (abs ~/ 100).toString();
  final fraction = (abs % 100).toString().padLeft(2, '0');
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$sign$symbol$grouped.$fraction';
}

/// Parses user input such as `3.5` or `$3.50` to cents. Returns null when the
/// text is not a valid amount.
int? parseMoney(String text) {
  final clean = text.replaceAll(RegExp(r'[^0-9.]'), '');
  final match = RegExp(r'^(\d*)(?:\.(\d{0,2}))?$').firstMatch(clean);
  if (clean.isEmpty || clean == '.' || match == null) return null;
  final whole = int.tryParse(match[1]!.isEmpty ? '0' : match[1]!) ?? 0;
  final fraction = (match[2] ?? '').padRight(2, '0');
  return whole * 100 + int.parse(fraction);
}

/// Applies a rate in basis points (825 is 8.25%), rounding half up.
int applyBasisPoints(int cents, int basisPoints) =>
    (cents * basisPoints + 5000) ~/ 10000;

/// `825` becomes `8.25%`, `1000` becomes `10%`.
String formatBasisPoints(int basisPoints) {
  final whole = basisPoints ~/ 100;
  final fraction = basisPoints % 100;
  if (fraction == 0) return '$whole%';
  final digits = fraction.toString().padLeft(2, '0');
  return '$whole.${digits.endsWith('0') ? digits[0] : digits}%';
}

String formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}

String formatHour(int hour) {
  final display = hour % 12 == 0 ? 12 : hour % 12;
  return '$display ${hour < 12 ? 'AM' : 'PM'}';
}

String formatDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';

String formatDateTime(DateTime time) =>
    '${formatDate(time)}, ${time.year}  ${formatTime(time)}';

DateTime startOfDay(DateTime time) => DateTime(time.year, time.month, time.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
