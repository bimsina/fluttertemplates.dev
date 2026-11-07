import 'package:flutter/services.dart';

/// Groups card digits as 4242 4242 4242 4242.
class CardNumberFormatter extends TextInputFormatter {
  const CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(capped[i]);
    }
    return _atEnd(buffer.toString());
  }
}

/// Turns 1227 into 12/27 as the customer types.
class ExpiryFormatter extends TextInputFormatter {
  const ExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;
    return _atEnd(
      capped.length > 2
          ? '${capped.substring(0, 2)}/${capped.substring(2)}'
          : capped,
    );
  }
}

TextEditingValue _atEnd(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

String? validateStreet(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Enter your street address';
  if (text.length < 5) return 'That address looks too short';
  return null;
}

String? validatePhone(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Enter a phone number for the courier';
  if (digits.length < 7) return 'That number looks too short';
  return null;
}

String? validateCardName(String? value) =>
    (value?.trim() ?? '').isEmpty ? 'Enter the name on the card' : null;

String? validateCardNumber(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Enter your card number';
  if (digits.length != 16 || !_passesLuhn(digits)) {
    return 'Check the card number';
  }
  return null;
}

String? validateExpiry(String? value) {
  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value ?? '');
  if (match == null) return 'Use MM/YY';
  final month = int.parse(match[1]!);
  final year = 2000 + int.parse(match[2]!);
  if (month < 1 || month > 12) return 'Use MM/YY';
  final now = DateTime.now();
  if (year < now.year || (year == now.year && month < now.month)) {
    return 'Card expired';
  }
  return null;
}

String? validateCvc(String? value) =>
    RegExp(r'^\d{3,4}$').hasMatch(value ?? '') ? null : '3 or 4 digits';

bool _passesLuhn(String digits) {
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    var digit = int.parse(digits[digits.length - 1 - i]);
    if (i.isOdd) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 == 0;
}
