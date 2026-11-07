import 'formatting.dart';

/// The text typed on the amount keypad.
///
/// Kept as a string so that `12.`, `12.5` and `12.50` all display exactly as
/// typed, and converted to cents with integer math only. No doubles touch
/// money anywhere in this template.
class AmountInput {
  const AmountInput([this.text = '']);

  factory AmountInput.fromCents(int cents) {
    if (cents <= 0) return const AmountInput();
    final whole = cents ~/ 100;
    final fraction = cents % 100;
    if (fraction == 0) return AmountInput('$whole');
    return AmountInput('$whole.${fraction.toString().padLeft(2, '0')}');
  }

  static const int maxWholeDigits = 7;

  final String text;

  bool get isEmpty => text.isEmpty;

  /// Appends a digit or `.` and returns the new value. Keys that would make
  /// the amount invalid are ignored.
  AmountInput append(String key) {
    if (key == '.') {
      if (text.contains('.')) return this;
      return AmountInput(text.isEmpty ? '0.' : '$text.');
    }
    final dot = text.indexOf('.');
    if (dot >= 0) {
      final decimals = text.length - dot - 1;
      return decimals >= 2 ? this : AmountInput('$text$key');
    }
    if (text == '0') return AmountInput(key);
    if (text.length >= maxWholeDigits) return this;
    return AmountInput('$text$key');
  }

  AmountInput backspace() {
    if (text.isEmpty) return this;
    return AmountInput(text.substring(0, text.length - 1));
  }

  int get cents {
    if (text.isEmpty) return 0;
    final parts = text.split('.');
    final whole = int.parse(parts[0].isEmpty ? '0' : parts[0]);
    final fraction = parts.length > 1 ? parts[1].padRight(2, '0') : '00';
    return whole * 100 + int.parse(fraction);
  }

  /// The amount as it should appear on screen, keeping a trailing `.` or `0`.
  String get display {
    if (text.isEmpty) return '${currencySymbol}0';
    final parts = text.split('.');
    final whole = groupThousands(parts[0]);
    return parts.length > 1
        ? '$currencySymbol$whole.${parts[1]}'
        : '$currencySymbol$whole';
  }
}
