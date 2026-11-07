import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _cardPlaceholder = '•••• •••• •••• ••••';

/// Keeps digits only, caps them at 16 and groups them in fours.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final nonDigit = RegExp(r'\D');
    final digits = newValue.text.replaceAll(nonDigit, '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(capped[i]);
    }

    // Keep the cursor after the same digit it followed before formatting.
    final end = newValue.selection.end.clamp(0, newValue.text.length);
    final before = newValue.text
        .substring(0, end)
        .replaceAll(nonDigit, '')
        .length
        .clamp(0, capped.length);
    final offset = before == 0 ? 0 : before + (before - 1) ~/ 4;

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Keeps digits only, caps them at four and writes them as MM/YY.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = capped.length > 2
        ? '${capped.substring(0, 2)}/${capped.substring(2)}'
        : capped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// The validated form values. Hand these to your payment provider's SDK.
class PaymentDetails {
  /// Digits only, without the grouping spaces.
  final String cardNumber;

  /// As typed, in MM/YY form.
  final String expiry;
  final String cvv;
  final String nameOnCard;

  const PaymentDetails({
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.nameOnCard,
  });
}

class PaymentForm extends StatefulWidget {
  /// Called with the card details once every field validates. Without it the
  /// demo shows a SnackBar.
  final ValueChanged<PaymentDetails>? onSubmit;

  const PaymentForm({super.key, this.onSubmit});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  var _cardDisplay = _cardPlaceholder;
  var _submitted = false;

  @override
  void initState() {
    super.initState();
    _cardController.addListener(() {
      final text = _cardController.text;
      setState(() => _cardDisplay = text.isEmpty ? _cardPlaceholder : text);
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _cardDigits => _cardController.text.replaceAll(' ', '');

  /// The Luhn checksum, which catches mistyped card numbers.
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

  String? _validateCard(String? _) {
    final digits = _cardDigits;
    if (digits.isEmpty) return 'Enter your card number';
    if (digits.length != 16 || !_passesLuhn(digits)) {
      return 'Enter a valid card number';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    final match = RegExp(r'^(\d\d)/(\d\d)$').firstMatch(value ?? '');
    final month = int.tryParse(match?.group(1) ?? '') ?? 0;
    if (month < 1 || month > 12) return 'Use MM/YY';
    final year = 2000 + int.parse(match!.group(2)!);
    // A card is valid through the last day of its expiry month.
    if (!DateTime(year, month + 1).isAfter(DateTime.now())) {
      return 'Card has expired';
    }
    return null;
  }

  String? _validateCvv(String? value) =>
      RegExp(r'^\d{3,4}$').hasMatch(value ?? '') ? null : 'Enter 3 or 4 digits';

  String? _validateName(String? value) =>
      (value ?? '').trim().isEmpty ? 'Enter the name on the card' : null;

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final details = PaymentDetails(
      cardNumber: _cardDigits,
      expiry: _expiryController.text,
      cvv: _cvvController.text,
      nameOnCard: _nameController.text.trim(),
    );
    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      onSubmit(details);
      return;
    }
    final last4 = details.cardNumber.substring(12);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Demo payment accepted for card ending $last4')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Form')),
      body: Form(
        key: _formKey,
        // Quiet until the first Pay press, then errors clear as they're fixed.
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cardDisplay,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Exp: MM/YY',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          'CVV: ***',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _cardController,
              validator: _validateCard,
              autofillHints: const [AutofillHints.creditCardNumber],
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
                hintText: '1234 5678 9012 3456',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [_CardNumberFormatter()],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    validator: _validateExpiry,
                    autofillHints: const [
                      AutofillHints.creditCardExpirationDate,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ExpiryFormatter()],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    validator: _validateCvv,
                    autofillHints: const [AutofillHints.creditCardSecurityCode],
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              validator: _validateName,
              autofillHints: const [AutofillHints.creditCardName],
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name on Card',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Pay')),
          ],
        ),
      ),
    );
  }
}
