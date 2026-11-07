import 'package:flutter/foundation.dart';

/// The signed-in person, as the UI needs them.
///
/// Map your provider's user type onto this in your repository, so screens
/// never import a backend SDK.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
    required this.lastSignInAt,
  });

  final String id;
  final String email;
  final String name;
  final bool emailVerified;
  final DateTime lastSignInAt;

  /// Up to two letters for the avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return letters.isEmpty ? email[0].toUpperCase() : letters;
  }

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.first.isEmpty ? email : parts.first;
  }
}
