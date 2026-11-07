import 'package:flutter/foundation.dart';

/// One requirement shown under a new password field.
@immutable
class PasswordRule {
  const PasswordRule(this.label, {required this.passed});

  final String label;
  final bool passed;
}

/// A local estimate of password strength, used for live feedback.
///
/// This is a guide, not a security boundary. Enforce your policy on the server
/// too. Supabase and Firebase both have password policy settings.
@immutable
class PasswordStrength {
  const PasswordStrength._(this.score, this.rules);

  static const minLength = 8;

  static const _common = {
    '12345678',
    '123456789',
    '1234567890',
    'qwerty123',
    'qwertyuiop',
    'letmein1',
    'iloveyou1',
    'admin123',
    'welcome1',
    'abc12345',
  };

  factory PasswordStrength.of(String password, {String? email}) {
    final lower = password.toLowerCase();
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasMixedCase =
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password);
    final hasSymbol = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);

    final mailbox = email?.split('@').first.toLowerCase() ?? '';
    final isGuessable =
        _common.contains(lower) ||
        lower.contains('password') ||
        (mailbox.length >= 3 && lower.contains(mailbox));

    final rules = [
      PasswordRule(
        'At least $minLength characters',
        passed: password.length >= minLength,
      ),
      PasswordRule(
        'A letter and a number',
        passed: hasLetter && hasNumber,
      ),
      PasswordRule(
        'Not common or based on your email',
        passed: password.isNotEmpty && !isGuessable,
      ),
    ];

    var score = 0;
    if (password.isNotEmpty) {
      score = 1;
      if (rules.every((rule) => rule.passed)) {
        score = 2;
        if (password.length >= 12) score++;
        if ((hasMixedCase && hasSymbol) || password.length >= 16) score++;
      }
    }
    return PasswordStrength._(score.clamp(0, 4), rules);
  }

  /// 0 for empty, then 1 to 4.
  final int score;
  final List<PasswordRule> rules;

  /// Whether the password is acceptable. Every rule has to pass.
  bool get isAcceptable => rules.every((rule) => rule.passed);

  String get label => switch (score) {
    0 => 'Not set',
    1 => 'Too weak',
    2 => 'Fair',
    3 => 'Good',
    _ => 'Strong',
  };
}
