import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/auth_event.dart';
import '../models/auth_failure.dart';
import '../models/auth_user.dart';

enum AuthStatus { restoring, signedOut, awaitingVerification, signedIn }

enum NoticeTone { info, success, warning }

/// A message that outlives the screen that caused it, such as "your session
/// expired" appearing after every signed-in screen has gone.
@immutable
class AuthNotice {
  const AuthNotice(this.message, this.tone);

  final String message;
  final NoticeTone tone;
}

/// The single source of truth for who is signed in.
///
/// [status] and [recovery] only change here, and only in response to
/// repository events. Routing is derived from them in `AuthNavigation`.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;
  StreamSubscription<AuthEvent>? _subscription;
  int _restoreRun = 0;
  bool _isDisposed = false;

  AuthStatus _status = AuthStatus.restoring;
  AuthStatus get status => _status;

  AuthUser? _user;
  AuthUser? get user => _user;

  /// Set while a reset link is being acted on. Kept apart from [status]
  /// because a recovery can start, and must survive, in any status.
  PasswordRecovery? _recovery;
  PasswordRecovery? get recovery => _recovery;

  AuthFailure? _restoreFailure;

  /// Why restoring the session failed. The splash screen offers a retry.
  AuthFailure? get restoreFailure => _restoreFailure;

  AuthNotice? _notice;
  AuthNotice? get notice => _notice;

  /// The address to carry between the signed-out forms.
  String draftEmail = '';

  int _signInPrefill = 0;

  /// Goes up when the sign-in form should replace its contents with
  /// [draftEmail] and clear its password.
  int get signInPrefill => _signInPrefill;

  /// Starts listening, then restores any stored session. Listening comes first
  /// so a reset link that opened the app isn't missed.
  void start() {
    _subscription ??= _repository.events.listen(
      _onEvent,
      onError: _onEventError,
    );
    unawaited(restore());
  }

  /// Runs session restore, showing the splash screen until it finishes.
  Future<void> restore() async {
    final run = ++_restoreRun;
    _status = AuthStatus.restoring;
    _user = null;
    _restoreFailure = null;
    _notifySafely();
    try {
      final user = await _repository.restoreSession();
      if (run != _restoreRun) return;
      _setUser(user);
    } on AuthFailure catch (failure) {
      if (run != _restoreRun) return;
      _restoreFailure = failure;
      _notifySafely();
    } catch (_) {
      if (run != _restoreRun) return;
      _restoreFailure = const AuthFailure(AuthFailureCode.unknown);
      _notifySafely();
    }
  }

  /// Leaves the splash screen without a session after restore failed.
  void continueSignedOut() {
    _restoreRun++;
    _restoreFailure = null;
    _setUser(null);
  }

  Future<void> signIn({required String email, required String password}) =>
      _call(() => _repository.signIn(email: email, password: password));

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _call(
    () => _repository.signUp(name: name, email: email, password: password),
  );

  Future<void> verifyEmail(String code) =>
      _call(() => _repository.verifyEmail(code: code));

  Future<void> resendVerification() => _call(_repository.resendVerification);

  Future<void> sendPasswordReset(String email) =>
      _call(() => _repository.sendPasswordReset(email: email));

  /// Sets the new password for the open [recovery] and closes it.
  Future<void> completeRecovery(String newPassword) async {
    final recovery = _recovery;
    if (recovery == null) return;
    await _call(
      () => _repository.completePasswordReset(
        token: recovery.token,
        newPassword: newPassword,
      ),
    );
    // A newer link replaced this one while the request ran. Leave it open.
    if (!identical(_recovery, recovery)) return;
    _recovery = null;
    final user = _user;
    if (user == null) {
      prefillSignIn(recovery.email);
      _notice = const AuthNotice(
        'Password updated. Sign in with your new password.',
        NoticeTone.success,
      );
    } else if (user.email == recovery.email) {
      _notice = const AuthNotice('Password updated.', NoticeTone.success);
    } else {
      _notice = AuthNotice(
        'Password updated for ${recovery.email}.',
        NoticeTone.success,
      );
    }
    _notifySafely();
  }

  /// Closes the recovery screen, returning to whatever was underneath.
  void dismissRecovery() {
    if (_recovery == null) return;
    _recovery = null;
    _notifySafely();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _call(
      () => _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    _notice = const AuthNotice('Password changed.', NoticeTone.success);
    _notifySafely();
  }

  Future<void> signOut() => _call(_repository.signOut);

  Future<void> deleteAccount(String password) =>
      _call(() => _repository.deleteAccount(password: password));

  void prefillSignIn(String email) {
    draftEmail = email;
    _signInPrefill++;
    _notifySafely();
  }

  void dismissNotice() {
    if (_notice == null) return;
    _notice = null;
    _notifySafely();
  }

  /// Runs a request. Every failure comes out as an [AuthFailure], and a dead
  /// session ends here, whichever screen happened to find out.
  Future<void> _call(Future<void> Function() request) async {
    dismissNotice();
    try {
      await request();
    } on AuthFailure catch (failure) {
      if (failure.code == AuthFailureCode.sessionExpired) {
        _endSession(SessionEndReason.expired);
      }
      rethrow;
    } catch (_) {
      throw const AuthFailure(AuthFailureCode.unknown);
    }
  }

  void _onEvent(AuthEvent event) {
    switch (event) {
      case SessionChanged(:final user):
        // Newer than anything a restore in flight could report.
        _restoreRun++;
        _restoreFailure = null;
        _setUser(user);
      case SessionEnded(:final reason):
        _restoreRun++;
        _restoreFailure = null;
        _endSession(reason);
      case PasswordRecoveryStarted(:final recovery):
        _recovery = recovery;
        _notifySafely();
    }
  }

  /// A failing stream says nothing about the session, so status, user and any
  /// open recovery all stay. Only a [SessionEnded] event signs anyone out.
  void _onEventError(Object error, StackTrace stackTrace) {
    debugPrint('Auth event stream failed: $error\n$stackTrace');
    _notice = AuthNotice(
      _user == null
          ? 'We couldn\'t reach the session service. Try again if something '
                'doesn\'t update.'
          : 'We couldn\'t reach the session service. You\'re still signed in.',
      NoticeTone.warning,
    );
    _notifySafely();
  }

  void _setUser(AuthUser? user) {
    final previous = _status;
    _user = user;
    if (user != null) {
      // Don't offer this address to whoever uses the sign-in form next.
      draftEmail = '';
      _signInPrefill = 0;
    }
    _status = switch (user) {
      null => AuthStatus.signedOut,
      AuthUser(emailVerified: false) => AuthStatus.awaitingVerification,
      _ => AuthStatus.signedIn,
    };
    if (previous == AuthStatus.awaitingVerification &&
        _status == AuthStatus.signedIn) {
      _notice = const AuthNotice(
        'Email verified. You\'re signed in.',
        NoticeTone.success,
      );
    }
    _notifySafely();
  }

  void _endSession(SessionEndReason reason) {
    final previous = _user;
    final wasSignedIn = _status == AuthStatus.signedIn;
    final hadSession = previous != null;
    _user = null;
    _status = AuthStatus.signedOut;
    switch (reason) {
      case SessionEndReason.expired when hadSession:
        prefillSignIn(previous.email);
        _notice = const AuthNotice(
          'Your session expired. Sign in again to continue.',
          NoticeTone.warning,
        );
      case SessionEndReason.signedOut when wasSignedIn:
        _notice = const AuthNotice('You\'re signed out.', NoticeTone.info);
      case SessionEndReason.accountDeleted:
        _notice = const AuthNotice(
          'Your account was deleted.',
          NoticeTone.info,
        );
      default:
        break;
    }
    _notifySafely();
  }

  void _notifySafely() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
