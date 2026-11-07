import 'package:flutter/foundation.dart';

import 'auth_user.dart';

/// Something that happened to the session, wherever it came from.
///
/// [AuthRepository.events] is the only way session state reaches the app. A
/// sign-in form doesn't navigate on success. It waits for [SessionChanged], the
/// same way it would if the session arrived from another tab or a refresh.
sealed class AuthEvent {
  const AuthEvent();
}

/// A session started, or the user on it changed. Unverified users count: they
/// hold a session that only reaches the verification step.
class SessionChanged extends AuthEvent {
  const SessionChanged(this.user);

  final AuthUser user;
}

enum SessionEndReason { signedOut, expired, accountDeleted }

class SessionEnded extends AuthEvent {
  const SessionEnded(this.reason);

  final SessionEndReason reason;
}

/// A password reset link was opened. This can arrive at any moment, signed in
/// or out, on top of any screen.
class PasswordRecoveryStarted extends AuthEvent {
  const PasswordRecoveryStarted(this.recovery);

  final PasswordRecovery recovery;
}

/// Proof that the holder opened a reset link.
@immutable
class PasswordRecovery {
  const PasswordRecovery({required this.email, required this.token});

  final String email;
  final String token;
}
