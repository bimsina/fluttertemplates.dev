/// Why an auth call failed. Repositories translate provider errors into these,
/// so screens can react without knowing which backend is connected.
enum AuthFailureCode {
  /// Unknown email or wrong password. Deliberately one case, so the sign-in
  /// form can't be used to find out who has an account.
  invalidCredentials,

  /// The password typed to confirm a sensitive action was wrong.
  wrongPassword,
  emailTaken,
  weakPassword,
  invalidCode,
  expiredCode,
  expiredLink,
  rateLimited,
  network,
  sessionExpired,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;

  /// True when sending the same request again could work.
  bool get isRetryable =>
      code == AuthFailureCode.network || code == AuthFailureCode.unknown;

  String get message => switch (code) {
    AuthFailureCode.invalidCredentials =>
      'That email and password don\'t match. Check them and try again.',
    AuthFailureCode.wrongPassword => 'That password isn\'t right.',
    AuthFailureCode.emailTaken => 'There is already an account with this email.',
    AuthFailureCode.weakPassword => 'Choose a stronger password.',
    AuthFailureCode.invalidCode => 'That code isn\'t right. Check it and retype.',
    AuthFailureCode.expiredCode =>
      'This code has expired. Send a new one to continue.',
    AuthFailureCode.expiredLink =>
      'This reset link has expired or was already used.',
    AuthFailureCode.rateLimited =>
      'Too many attempts. Wait a minute and try again.',
    AuthFailureCode.network =>
      'Couldn\'t reach the server. Nothing was changed, so it\'s safe to retry.',
    AuthFailureCode.sessionExpired => 'Your session has expired.',
    AuthFailureCode.unknown => 'Something went wrong. Please try again.',
  };

  @override
  String toString() => 'AuthFailure(${code.name})';
}
