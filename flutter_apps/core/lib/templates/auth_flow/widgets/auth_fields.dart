import 'package:flutter/material.dart';

/// Null when [value] looks like an email address. The server has the last
/// word, so this only catches typos.
String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'That doesn\'t look like an email address.';
  }
  return null;
}

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onNext,
    this.onDone,
    this.isEnabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Moves on to the next field. The keyboard shows Done without it.
  final VoidCallback? onNext;
  final VoidCallback? onDone;
  final bool isEnabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: isEnabled,
      autofocus: autofocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: onNext != null
          ? TextInputAction.next
          : TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: validateEmail,
      onEditingComplete: onNext,
      onFieldSubmitted: onDone == null ? null : (_) => onDone!(),
    );
  }
}

/// A password field with a show and hide button.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.autofillHint,
    this.validator,
    this.onChanged,
    this.onNext,
    this.onDone,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;

  /// [AutofillHints.password] for an existing password, and
  /// [AutofillHints.newPassword] when setting one, so password managers offer
  /// the right thing.
  final String autofillHint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  /// Moves straight to the next text field. The default "next" action would
  /// land on the show password button instead.
  final VoidCallback? onNext;
  final VoidCallback? onDone;
  final bool autofocus;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      obscureText: !_isVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.onNext != null
          ? TextInputAction.next
          : TextInputAction.done,
      autofillHints: [widget.autofillHint],
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _isVisible = !_isVisible),
          tooltip: _isVisible
              ? 'Hide ${widget.label.toLowerCase()}'
              : 'Show ${widget.label.toLowerCase()}',
          icon: Icon(
            _isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onNext,
      onFieldSubmitted: widget.onDone == null
          ? null
          : (_) => widget.onDone!(),
    );
  }
}
