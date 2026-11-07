import '../models/auth_event.dart';
import '../models/auth_user.dart';

/// Everything the app needs from an auth backend.
///
/// Screens and state only know this interface. To connect a real service,
/// implement it and return it from `createDefaultRepository()` in
/// `default_repository.dart`.
///
/// Three rules every implementation follows:
///
/// * Failures throw `AuthFailure`. Translate provider errors in here.
/// * Session changes are reported through [events], not return values. Methods
///   complete when the request is done and the app reacts to the event.
/// * Retrying must be safe. A request whose response was lost may be sent
///   again, so a repeated [signUp] or [verifyEmail] shouldn't fail because the
///   first one worked.
abstract class AuthRepository {
  /// Session changes, recovery links included. Must be a broadcast stream.
  ///
  /// An error on this stream shows a warning and changes nothing else, so it
  /// never signs anyone out. To end a session, add [SessionEnded].
  ///
  /// SWAP POINT (Supabase): map `client.auth.onAuthStateChange`.
  /// `passwordRecovery` becomes [PasswordRecoveryStarted]. `signedOut` with no
  /// [signOut] call in progress becomes `SessionEnded(expired)`.
  ///
  /// SWAP POINT (Firebase): map `authStateChanges()`. Firebase has no recovery
  /// event. Listen for your reset deep link and add [PasswordRecoveryStarted]
  /// with the link's `oobCode` as the token.
  Stream<AuthEvent> get events;

  /// Returns the stored session's user, or null when there isn't one.
  /// Runs behind the splash screen. Throw to show the retry option.
  ///
  /// SWAP POINT (Supabase): `client.auth.currentSession`, after initialize.
  /// SWAP POINT (Firebase): first value of `authStateChanges()`.
  Future<AuthUser?> restoreSession();

  /// Throws [AuthFailureCode.invalidCredentials] for an unknown email or a
  /// wrong password. An unverified account still starts a session, reported
  /// with `emailVerified: false`, and gets a fresh code.
  ///
  /// SWAP POINT (Supabase): `signInWithPassword`. With email confirmation on,
  /// catch `email_not_confirmed`, resend, and emit an unverified user.
  /// SWAP POINT (Firebase): `signInWithEmailAndPassword`.
  Future<void> signIn({required String email, required String password});

  /// Creates an account and sends a verification code.
  ///
  /// SWAP POINT (Supabase): `signUp`, with `data: {'name': name}`.
  /// SWAP POINT (Firebase): `createUserWithEmailAndPassword`, then
  /// `updateDisplayName` and `sendEmailVerification`.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Throws [AuthFailureCode.invalidCode] or [AuthFailureCode.expiredCode].
  ///
  /// SWAP POINT (Supabase): `verifyOTP(type: OtpType.signup, ...)`. The email
  /// template must include `{{ .Token }}`.
  /// SWAP POINT (Firebase): verification is link based. See the template notes
  /// for replacing this step.
  Future<void> verifyEmail({required String code});

  /// Sends a new code. Any earlier code stops working.
  ///
  /// SWAP POINT (Supabase): `resend(type: OtpType.signup, email: ...)`.
  /// SWAP POINT (Firebase): `currentUser.sendEmailVerification()`.
  Future<void> resendVerification();

  /// Sends a reset link. Completes normally for unknown addresses, so this
  /// can't be used to find out who has an account.
  ///
  /// SWAP POINT (Supabase): `resetPasswordForEmail(email, redirectTo: ...)`.
  /// SWAP POINT (Firebase): `sendPasswordResetEmail(email: ...)`.
  Future<void> sendPasswordReset({required String email});

  /// Sets a new password using the token from [PasswordRecoveryStarted].
  /// Throws [AuthFailureCode.expiredLink] if the token is no longer valid.
  ///
  /// SWAP POINT (Supabase): `updateUser(UserAttributes(password: ...))`. The
  /// recovery event already signed the user in, so the token isn't needed.
  /// SWAP POINT (Firebase): `confirmPasswordReset(code: token, ...)`.
  Future<void> completePasswordReset({
    required String token,
    required String newPassword,
  });

  /// Throws [AuthFailureCode.wrongPassword] if [currentPassword] is wrong.
  ///
  /// SWAP POINT (Supabase): check with `signInWithPassword`, then `updateUser`.
  /// SWAP POINT (Firebase): `reauthenticateWithCredential`, `updatePassword`.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// SWAP POINT (Supabase): `signOut()`.
  /// SWAP POINT (Firebase): `signOut()`.
  Future<void> signOut();

  /// Throws [AuthFailureCode.wrongPassword] if [password] is wrong.
  ///
  /// SWAP POINT (Supabase): clients can't delete users. Call an Edge Function
  /// that uses the service role key, then `signOut()`.
  /// SWAP POINT (Firebase): `reauthenticateWithCredential`, `currentUser.delete()`.
  Future<void> deleteAccount({required String password});

  /// Called by the app for the repository from `createDefaultRepository()`.
  /// One you pass to `AuthFlowApp(repository: ...)` stays yours to dispose.
  void dispose();
}
