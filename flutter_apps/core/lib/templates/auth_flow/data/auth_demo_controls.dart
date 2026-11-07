import 'package:flutter/foundation.dart';

/// What a real backend does out of sight, exposed so the demo can show it:
/// the contents of emails, and ways to force failures.
///
/// The UI only renders demo panels when the repository implements this, so
/// they disappear on their own with a real repository. The template notes list
/// what to remove if you want this file and `widgets/demo_panels.dart` gone.
abstract interface class AuthDemoControls implements Listenable {
  /// The demo login, kept current if the password is changed in the demo.
  /// Null after the demo account is deleted.
  DemoCredentials? get demoAccount;

  /// The latest email that would have carried a verification code.
  DemoEmail? get verificationEmail;

  /// The latest password reset email.
  DemoEmail? get resetEmail;

  /// When true, the next request fails with a network error before it does
  /// anything, then this switches itself off.
  bool get failNextRequest;
  set failNextRequest(bool value);

  /// Expires the code or link in [verificationEmail] and [resetEmail].
  void expireVerificationCode();
  void expireResetLink();

  /// Acts as if the reset link in the latest email was tapped. If there isn't
  /// one, sends a reset email to the current or demo account first.
  void openRecoveryLink();

  /// Ends the session as if it expired on the server. With [notify] false the
  /// app isn't told, and finds out from its next request.
  void expireSession({bool notify = true});

  /// Brings back the demo account with its original password.
  void restoreDemoAccount();
}

@immutable
class DemoCredentials {
  const DemoCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

@immutable
class DemoEmail {
  const DemoEmail({
    required this.to,
    this.code,
    this.isDelivered = true,
    this.isExpired = false,
  });

  final String to;

  /// The verification code, for [AuthDemoControls.verificationEmail].
  final String? code;

  /// False if no account uses [to], so nothing was sent.
  final bool isDelivered;
  final bool isExpired;
}
