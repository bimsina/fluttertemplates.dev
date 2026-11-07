import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/auth_event.dart';
import '../models/auth_failure.dart';
import '../models/auth_user.dart';
import '../models/password_strength.dart';
import 'auth_demo_controls.dart';
import 'auth_repository.dart';

/// An in-memory backend for the demo and for tests.
///
/// It behaves like a server: it adds latency, rejects wrong passwords and
/// taken emails, and expires codes. Everything lives in memory, so a page
/// reload starts over. Passwords are stored as plain text, which is only
/// acceptable because none of this is real.
///
/// SWAP POINT: replace this class with your own [AuthRepository], then delete
/// this file. See the notes in `auth_repository.dart`.
class FakeAuthRepository extends ChangeNotifier
    implements AuthRepository, AuthDemoControls {
  FakeAuthRepository({
    this.latency = const Duration(milliseconds: 650),
    this.codeLifetime = const Duration(minutes: 10),
    this.linkLifetime = const Duration(hours: 1),
    DateTime Function()? clock,
    Random? random,
  }) : _now = clock ?? DateTime.now,
       _random = random ?? Random() {
    _seedDemoAccount();
  }

  static const demoEmail = 'demo@example.com';
  static const demoPassword = 'Latchkey-2048';
  static const _demoId = 'user-demo';

  final Duration latency;
  final Duration codeLifetime;
  final Duration linkLifetime;
  final DateTime Function() _now;
  final Random _random;

  final _events = StreamController<AuthEvent>.broadcast();
  final Map<String, _Account> _accounts = {};

  _Account? _session;
  _Issued? _code;
  _Issued? _link;
  DemoEmail? _verificationEmail;
  DemoEmail? _resetEmail;
  bool _failNextRequest = false;
  int _nextId = 1;

  void _seedDemoAccount() {
    _accounts[demoEmail] = _Account(
      id: _demoId,
      name: 'Demo User',
      email: demoEmail,
      password: demoPassword,
      verified: true,
    );
  }

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }

  // AuthRepository

  @override
  Stream<AuthEvent> get events => _events.stream;

  @override
  Future<AuthUser?> restoreSession() async {
    await _request();
    return _session?.toUser(_now());
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _request();
    final account = _accounts[_normalize(email)];
    if (account == null || account.password != password) {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    if (!account.verified) _issueCode(account);
    _startSession(account);
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _request();
    final address = _normalize(email);
    if (!PasswordStrength.of(password, email: address).isAcceptable) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }
    final existing = _accounts[address];
    if (existing != null) {
      // The same details again means the first response was lost, or the
      // person left before verifying. Carry on rather than call it taken.
      final isRetry = !existing.verified && existing.password == password;
      if (!isRetry) throw const AuthFailure(AuthFailureCode.emailTaken);
      _issueCode(existing);
      _startSession(existing);
      return;
    }
    final account = _Account(
      id: 'user-${_nextId++}',
      name: name.trim(),
      email: address,
      password: password,
      verified: false,
    );
    _accounts[address] = account;
    _issueCode(account);
    _startSession(account);
  }

  @override
  Future<void> verifyEmail({required String code}) async {
    await _request();
    final account = _requireSession();
    if (!account.verified) {
      final issued = _code;
      if (issued == null || issued.isExpiredAt(_now())) {
        throw const AuthFailure(AuthFailureCode.expiredCode);
      }
      if (issued.value != code) {
        throw const AuthFailure(AuthFailureCode.invalidCode);
      }
      account.verified = true;
      _code = null;
      _verificationEmail = null;
      notifyListeners();
    }
    _events.add(SessionChanged(account.toUser(_now())));
  }

  @override
  Future<void> resendVerification() async {
    await _request();
    _issueCode(_requireSession());
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await _request();
    final address = _normalize(email);
    final account = _accounts[address];
    if (account == null) {
      _link = null;
      _resetEmail = DemoEmail(to: address, isDelivered: false);
      notifyListeners();
      return;
    }
    _issueLink(account);
  }

  @override
  Future<void> completePasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _request();
    final link = _link;
    final account = link == null ? null : _accounts[link.email];
    if (link == null ||
        account == null ||
        link.value != token ||
        link.isExpiredAt(_now())) {
      throw const AuthFailure(AuthFailureCode.expiredLink);
    }
    if (!PasswordStrength.of(newPassword, email: link.email).isAcceptable) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }
    account.password = newPassword;
    _link = null;
    _resetEmail = null;
    notifyListeners();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _request();
    final account = _requireSession();
    if (account.password != currentPassword) {
      throw const AuthFailure(AuthFailureCode.wrongPassword);
    }
    if (!PasswordStrength.of(newPassword, email: account.email).isAcceptable) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }
    account.password = newPassword;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    await _request();
    _session = null;
    _events.add(const SessionEnded(SessionEndReason.signedOut));
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    await _request();
    final account = _requireSession();
    if (account.password != password) {
      throw const AuthFailure(AuthFailureCode.wrongPassword);
    }
    _accounts.remove(account.email);
    _session = null;
    if (_link?.email == account.email) {
      _link = null;
      _resetEmail = null;
    }
    notifyListeners();
    _events.add(const SessionEnded(SessionEndReason.accountDeleted));
  }

  // AuthDemoControls

  @override
  DemoCredentials? get demoAccount {
    final account = _accounts.values
        .where((account) => account.id == _demoId)
        .firstOrNull;
    if (account == null) return null;
    return DemoCredentials(email: account.email, password: account.password);
  }

  @override
  DemoEmail? get verificationEmail => _verificationEmail;

  @override
  DemoEmail? get resetEmail => _resetEmail;

  @override
  bool get failNextRequest => _failNextRequest;

  @override
  set failNextRequest(bool value) {
    if (_failNextRequest == value) return;
    _failNextRequest = value;
    notifyListeners();
  }

  @override
  void expireVerificationCode() {
    final email = _verificationEmail;
    if (email == null) return;
    _code?.forceExpired = true;
    _verificationEmail = DemoEmail(
      to: email.to,
      code: email.code,
      isExpired: true,
    );
    notifyListeners();
  }

  @override
  void expireResetLink() {
    final email = _resetEmail;
    if (email == null || !email.isDelivered) return;
    _link?.forceExpired = true;
    _resetEmail = DemoEmail(to: email.to, isExpired: true);
    notifyListeners();
  }

  @override
  void openRecoveryLink() {
    var link = _link;
    if (link == null) {
      final account = _session ?? _accounts[demoEmail];
      if (account == null) return;
      link = _issueLink(account);
    }
    _events.add(
      PasswordRecoveryStarted(
        PasswordRecovery(email: link.email, token: link.value),
      ),
    );
  }

  @override
  void expireSession({bool notify = true}) {
    if (_session == null) return;
    _session = null;
    if (notify) _events.add(const SessionEnded(SessionEndReason.expired));
  }

  @override
  void restoreDemoAccount() {
    _seedDemoAccount();
    notifyListeners();
  }

  // Internals

  String _normalize(String email) => email.trim().toLowerCase();

  /// Every request waits, and may be told to fail before changing anything.
  /// That is why a network failure is always safe to retry here.
  Future<void> _request() async {
    await Future<void>.delayed(latency);
    if (_failNextRequest) {
      _failNextRequest = false;
      notifyListeners();
      throw const AuthFailure(AuthFailureCode.network);
    }
  }

  _Account _requireSession() {
    final session = _session;
    if (session == null) {
      throw const AuthFailure(AuthFailureCode.sessionExpired);
    }
    return session;
  }

  void _startSession(_Account account) {
    _session = account;
    _events.add(SessionChanged(account.toUser(_now())));
  }

  void _issueCode(_Account account) {
    final value = _random.nextInt(1000000).toString().padLeft(6, '0');
    _code = _Issued(
      value: value,
      email: account.email,
      expiresAt: _now().add(codeLifetime),
    );
    _verificationEmail = DemoEmail(to: account.email, code: value);
    notifyListeners();
  }

  _Issued _issueLink(_Account account) {
    final link = _Issued(
      value: 'reset-${_random.nextInt(1000000000)}',
      email: account.email,
      expiresAt: _now().add(linkLifetime),
    );
    _link = link;
    _resetEmail = DemoEmail(to: account.email);
    notifyListeners();
    return link;
  }
}

class _Account {
  _Account({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.verified,
  });

  final String id;
  final String name;
  final String email;
  String password;
  bool verified;

  AuthUser toUser(DateTime signedInAt) => AuthUser(
    id: id,
    email: email,
    name: name,
    emailVerified: verified,
    lastSignInAt: signedInAt,
  );
}

/// A code or link the fake "emailed".
class _Issued {
  _Issued({required this.value, required this.email, required this.expiresAt});

  final String value;
  final String email;
  final DateTime expiresAt;
  bool forceExpired = false;

  bool isExpiredAt(DateTime now) => forceExpired || now.isAfter(expiresAt);
}
