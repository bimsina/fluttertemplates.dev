import 'package:core/templates/auth_flow/data/fake_auth_repository.dart';
import 'package:core/templates/auth_flow/models/auth_event.dart';
import 'package:core/templates/auth_flow/models/auth_failure.dart';
import 'package:core/templates/auth_flow/models/password_strength.dart';
import 'package:core/templates/auth_flow/state/auth_controller.dart';
import 'package:core/templates/auth_flow/state/auth_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher failsWith(AuthFailureCode code) =>
    throwsA(isA<AuthFailure>().having((failure) => failure.code, 'code', code));

const demoEmail = FakeAuthRepository.demoEmail;
const demoPassword = FakeAuthRepository.demoPassword;
const goodPassword = 'Analytical-Engine-1843';

void main() {
  group('PasswordStrength', () {
    test('scores from empty to strong', () {
      expect(PasswordStrength.of('').score, 0);
      expect(PasswordStrength.of('abc').score, 1);
      expect(PasswordStrength.of('horse1battery').score, 3);
      expect(PasswordStrength.of('abcd1234').score, 2);
      expect(PasswordStrength.of('Horse-1-Battery').score, 4);
    });

    test('rejects common passwords and ones based on the email', () {
      expect(PasswordStrength.of('password123').isAcceptable, isFalse);
      expect(PasswordStrength.of('12345678').isAcceptable, isFalse);
      expect(
        PasswordStrength.of('ada12345', email: 'ada@example.com').isAcceptable,
        isFalse,
      );
    });

    test('an empty password passes no rules', () {
      expect(
        PasswordStrength.of('').rules.where((rule) => rule.passed),
        isEmpty,
      );
    });
  });

  group('FakeAuthRepository', () {
    late DateTime now;
    late FakeAuthRepository fake;

    setUp(() {
      now = DateTime(2026, 1, 1, 12);
      fake = FakeAuthRepository(latency: Duration.zero, clock: () => now);
    });

    tearDown(() => fake.dispose());

    test('wrong password and unknown email fail identically', () async {
      await expectLater(
        fake.signIn(email: demoEmail, password: 'nope'),
        failsWith(AuthFailureCode.invalidCredentials),
      );
      await expectLater(
        fake.signIn(email: 'x@example.com', password: demoPassword),
        failsWith(AuthFailureCode.invalidCredentials),
      );
    });

    test('email matching ignores case and spaces', () async {
      await fake.signIn(email: ' DEMO@example.com ', password: demoPassword);
      expect((await fake.restoreSession())?.email, demoEmail);
    });

    test('a verified email is taken', () async {
      await expectLater(
        fake.signUp(name: 'A', email: demoEmail, password: goodPassword),
        failsWith(AuthFailureCode.emailTaken),
      );
    });

    test('repeating an unverified sign-up is safe', () async {
      await fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword);
      await fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword);
      await expectLater(
        fake.signUp(name: 'A', email: 'a@b.co', password: 'Different-Pass-1'),
        failsWith(AuthFailureCode.emailTaken),
      );
    });

    test('the server side rejects a weak password too', () async {
      await expectLater(
        fake.signUp(name: 'A', email: 'a@b.co', password: 'short'),
        failsWith(AuthFailureCode.weakPassword),
      );
    });

    test('codes expire with time', () async {
      await fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword);
      final code = fake.verificationEmail!.code!;
      now = now.add(const Duration(minutes: 11));
      await expectLater(
        fake.verifyEmail(code: code),
        failsWith(AuthFailureCode.expiredCode),
      );
    });

    test('a resend makes the earlier code useless', () async {
      await fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword);
      final first = fake.verificationEmail!.code!;
      await fake.resendVerification();
      final second = fake.verificationEmail!.code!;
      if (first != second) {
        await expectLater(
          fake.verifyEmail(code: first),
          failsWith(AuthFailureCode.invalidCode),
        );
      }
      await fake.verifyEmail(code: second);
    });

    test('repeating a successful verification is safe', () async {
      await fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword);
      final code = fake.verificationEmail!.code!;
      await fake.verifyEmail(code: code);
      await fake.verifyEmail(code: code);
      expect((await fake.restoreSession())?.emailVerified, isTrue);
    });

    test('a reset link works once and expires with time', () async {
      final tokens = <String>[];
      final subscription = fake.events.listen((event) {
        if (event is PasswordRecoveryStarted) {
          tokens.add(event.recovery.token);
        }
      });
      addTearDown(subscription.cancel);

      await fake.sendPasswordReset(email: demoEmail);
      fake.openRecoveryLink();
      await pumpEventQueue();
      await fake.completePasswordReset(
        token: tokens.single,
        newPassword: goodPassword,
      );
      await expectLater(
        fake.completePasswordReset(
          token: tokens.single,
          newPassword: goodPassword,
        ),
        failsWith(AuthFailureCode.expiredLink),
      );

      await fake.sendPasswordReset(email: demoEmail);
      fake.openRecoveryLink();
      await pumpEventQueue();
      now = now.add(const Duration(hours: 2));
      await expectLater(
        fake.completePasswordReset(
          token: tokens.last,
          newPassword: 'Another-Good-Pass-2',
        ),
        failsWith(AuthFailureCode.expiredLink),
      );
    });

    test('a failed request changes nothing', () async {
      fake.failNextRequest = true;
      await expectLater(
        fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword),
        failsWith(AuthFailureCode.network),
      );
      expect(fake.failNextRequest, isFalse);
      await fake.signUp(name: 'A', email: 'a@b.co', password: goodPassword);
    });

    test('signed-in calls fail once the session is gone', () async {
      await fake.signIn(email: demoEmail, password: demoPassword);
      fake.expireSession(notify: false);
      await expectLater(
        fake.changePassword(
          currentPassword: demoPassword,
          newPassword: goodPassword,
        ),
        failsWith(AuthFailureCode.sessionExpired),
      );
    });
  });

  group('AuthController and AuthNavigation', () {
    late FakeAuthRepository fake;
    late AuthController auth;
    late AuthNavigation navigation;

    setUp(() async {
      fake = FakeAuthRepository(latency: Duration.zero);
      auth = AuthController(fake)..start();
      navigation = AuthNavigation(auth);
      await pumpEventQueue();
    });

    tearDown(() {
      navigation.dispose();
      auth.dispose();
      fake.dispose();
    });

    Future<void> signedIn() async {
      await auth.signIn(email: demoEmail, password: demoPassword);
      await pumpEventQueue();
    }

    test('the stack root follows the status', () async {
      expect(navigation.stack, [AuthRoute.signIn]);
      await signedIn();
      expect(navigation.stack, [AuthRoute.home]);
      await auth.signOut();
      await pumpEventQueue();
      expect(navigation.stack, [AuthRoute.signIn]);
    });

    test('recovery always comes last, whatever else opens', () async {
      await signedIn();
      navigation.open(AuthRoute.settings);
      fake.openRecoveryLink();
      await pumpEventQueue();
      navigation.open(AuthRoute.changePassword);
      expect(navigation.stack, [
        AuthRoute.home,
        AuthRoute.settings,
        AuthRoute.changePassword,
        AuthRoute.resetPassword,
      ]);

      fake.expireSession();
      await pumpEventQueue();
      expect(navigation.stack, [AuthRoute.signIn, AuthRoute.resetPassword]);
    });

    test('routes from another status are ignored', () async {
      navigation.open(AuthRoute.settings);
      expect(navigation.stack, [AuthRoute.signIn]);
      await signedIn();
      navigation.open(AuthRoute.signUp);
      expect(navigation.stack, [AuthRoute.home]);
    });

    test('opening a route twice adds it once', () async {
      await signedIn();
      navigation.open(AuthRoute.settings);
      navigation.open(AuthRoute.settings);
      expect(navigation.stack, [AuthRoute.home, AuthRoute.settings]);
    });

    test('a slow restore cannot undo a newer sign-in', () async {
      final slow = FakeAuthRepository(
        latency: const Duration(milliseconds: 30),
      );
      final controller = AuthController(slow)..start();
      addTearDown(() {
        controller.dispose();
        slow.dispose();
      });

      await slow.signIn(email: demoEmail, password: demoPassword);
      await pumpEventQueue();
      expect(controller.status, AuthStatus.signedIn);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.status, AuthStatus.signedIn);
    });

    test('a request that finds the session dead ends it once', () async {
      await signedIn();
      fake.expireSession(notify: false);
      await expectLater(
        auth.changePassword(
          currentPassword: demoPassword,
          newPassword: goodPassword,
        ),
        failsWith(AuthFailureCode.sessionExpired),
      );
      expect(auth.status, AuthStatus.signedOut);
      expect(auth.notice?.tone, NoticeTone.warning);
      expect(auth.draftEmail, demoEmail);
    });

    test('unexpected errors come out as AuthFailure', () async {
      final auth = AuthController(_ThrowingRepository(fake));
      addTearDown(auth.dispose);
      await expectLater(
        auth.signIn(email: demoEmail, password: demoPassword),
        failsWith(AuthFailureCode.unknown),
      );
    });
  });
}

class _ThrowingRepository extends FakeAuthRepository {
  _ThrowingRepository(FakeAuthRepository _) : super(latency: Duration.zero);

  @override
  Future<void> signIn({required String email, required String password}) {
    throw StateError('provider blew up');
  }
}
