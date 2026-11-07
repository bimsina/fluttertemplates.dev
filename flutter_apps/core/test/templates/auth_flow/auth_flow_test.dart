import 'package:core/templates/auth_flow/data/fake_auth_repository.dart';
import 'package:core/templates/auth_flow/screens/change_password_screen.dart';
import 'package:core/templates/auth_flow/screens/forgot_password_screen.dart';
import 'package:core/templates/auth_flow/screens/home_screen.dart';
import 'package:core/templates/auth_flow/screens/reset_password_screen.dart';
import 'package:core/templates/auth_flow/screens/settings_screen.dart';
import 'package:core/templates/auth_flow/screens/sign_in_screen.dart';
import 'package:core/templates/auth_flow/screens/sign_up_screen.dart';
import 'package:core/templates/auth_flow/screens/splash_screen.dart';
import 'package:core/templates/auth_flow/screens/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

const newPassword = 'Correct-Horse-Battery-9';

void main() {
  group('session restore', () {
    testWidgets('shows the splash, then sign in when there is no session', (
      tester,
    ) async {
      await pumpApp(tester, settle: false);
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Restoring your session'), findsOneWidget);

      await settleApp(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('a failed restore can be retried', (tester) async {
      final fake = FakeAuthRepository(latency: const Duration(milliseconds: 20))
        ..failNextRequest = true;
      await pumpApp(tester, repository: fake);

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.textContaining('Couldn\'t reach'), findsOneWidget);

      await tapText(tester, 'Try again');
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('a failed restore can be skipped', (tester) async {
      final fake = FakeAuthRepository(latency: const Duration(milliseconds: 20))
        ..failNextRequest = true;
      await pumpApp(tester, repository: fake);

      await tapText(tester, 'Continue to sign in');
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('relaunching keeps the session', (tester) async {
      await pumpApp(tester);
      await signIn(tester);

      await tester.ensureVisible(find.text('Relaunch app'));
      await tester.pump();
      await tester.tap(find.text('Relaunch app'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 5));
      await tester.pump(const Duration(milliseconds: 300));
      await settleApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('sign in', () {
    testWidgets('shows the demo account on the screen', (tester) async {
      await pumpApp(tester);
      expect(find.text(FakeAuthRepository.demoEmail), findsOneWidget);
      expect(find.text(FakeAuthRepository.demoPassword), findsOneWidget);

      await tapText(tester, 'Fill in demo account');
      await tapFinder(tester, find.widgetWithText(FilledButton, 'Sign in'));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('a wrong password fails visibly and can be corrected', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester, password: 'not-the-password');

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.textContaining('don\'t match'), findsOneWidget);
      // The email stays, and focus returns to the field to fix.
      expect(find.text(FakeAuthRepository.demoEmail), findsWidgets);
      final password = tester.widget<EditableText>(
        find.descendant(
          of: field('Password'),
          matching: find.byType(EditableText),
        ),
      );
      expect(password.focusNode.hasFocus, isTrue);

      await signIn(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('an unknown email fails the same way as a wrong password', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester, email: 'nobody@example.com');
      expect(find.textContaining('don\'t match'), findsOneWidget);
    });

    testWidgets('empty fields are caught before any request', (tester) async {
      await pumpApp(tester);
      await tapFinder(tester, find.widgetWithText(FilledButton, 'Sign in'));
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets('a network failure offers a retry that works', (tester) async {
      final fake = await pumpApp(tester);
      fake.failNextRequest = true;
      await signIn(tester);

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.textContaining('safe to retry'), findsOneWidget);

      await tapText(tester, 'Try again');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('submitting twice sends one request', (tester) async {
      final fake = _CountingRepository();
      await pumpApp(tester, repository: fake);
      await typeInto(tester, field('Email'), FakeAuthRepository.demoEmail);
      await typeInto(tester, field('Password'), 'wrong-password');

      await tester.showKeyboard(field('Password'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settleApp(tester);

      expect(fake.signInCalls, 1);
      expect(find.textContaining('don\'t match'), findsOneWidget);
    });
  });

  group('sign up', () {
    testWidgets('a weak password is blocked, with live feedback', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapText(tester, 'Create an account');
      expect(find.text('Not set'), findsOneWidget);

      await typeInto(tester, field('Name'), 'Ada');
      await typeInto(tester, field('Email'), 'ada@example.com');
      await typeInto(tester, field('Password'), 'password1');
      expect(find.text('Too weak'), findsOneWidget);

      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Create account'),
      );
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.textContaining('meet the rules'), findsOneWidget);

      await typeInto(tester, field('Password'), 'Analytical-Engine-1843');
      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets(
      'a taken email offers signing in, with the email carried over',
      (tester) async {
        await pumpApp(tester);
        await signUp(tester, email: FakeAuthRepository.demoEmail);

        expect(find.byType(SignUpScreen), findsOneWidget);
        expect(find.textContaining('already an account'), findsOneWidget);

        await tapText(tester, 'Sign in instead');
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.byType(SignUpScreen), findsNothing);
        final email = tester.widget<TextFormField>(field('Email'));
        expect(email.controller!.text, FakeAuthRepository.demoEmail);
      },
    );

    testWidgets('leads to verification, not the app', (tester) async {
      final fake = await pumpApp(tester);
      await signUp(tester);

      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(SignUpScreen, skipOffstage: false), findsNothing);
      expect(find.textContaining('ada@example.com'), findsOneWidget);
      // The demo code is on the screen.
      expect(find.text(fake.verificationEmail!.code!), findsOneWidget);
    });

    testWidgets('a network failure keeps what was typed', (tester) async {
      final fake = await pumpApp(tester);
      fake.failNextRequest = true;
      await signUp(tester);

      expect(find.byType(SignUpScreen), findsOneWidget);
      await tapText(tester, 'Try again');
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
    });
  });

  group('verify email', () {
    testWidgets('the right code lands on home', (tester) async {
      final fake = await pumpApp(tester);
      await signUp(tester);

      await tester.enterText(codeField, fake.verificationEmail!.code!);
      await settleApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Hello, Ada'), findsOneWidget);
      expect(find.textContaining('Email verified'), findsOneWidget);
    });

    testWidgets('a wrong code clears the boxes so it can be retyped', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signUp(tester);
      final code = fake.verificationEmail!.code!;
      final wrong = code == '000000' ? '111111' : '000000';

      await tester.enterText(codeField, wrong);
      await settleApp(tester);

      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(find.textContaining('isn\'t right'), findsOneWidget);
      expect(tester.widget<TextField>(codeField).controller!.text, isEmpty);

      await tester.enterText(codeField, code);
      await settleApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('an expired code can be replaced straight away', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signUp(tester);
      final oldCode = fake.verificationEmail!.code!;

      await tapText(tester, 'Expire it');
      await tester.enterText(codeField, oldCode);
      await settleApp(tester);
      expect(find.textContaining('has expired'), findsOneWidget);

      // No cooldown: the old code is useless.
      await tapFinder(
        tester,
        find.widgetWithText(TextButton, 'Send a new code'),
      );
      expect(find.text('A new code is on its way.'), findsOneWidget);
      final newCode = fake.verificationEmail!.code!;
      expect(find.text(newCode), findsOneWidget);

      await tester.enterText(codeField, newCode);
      await settleApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('resending waits out the cooldown', (tester) async {
      await pumpApp(tester);
      await signUp(tester);

      final waiting = find.textContaining('Send a new code in');
      expect(waiting, findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.ancestor(of: waiting, matching: find.byType(TextButton)),
            )
            .onPressed,
        isNull,
      );

      await tester.pump(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Send a new code'), findsOneWidget);
    });

    testWidgets('a different email returns to sign in', (tester) async {
      await pumpApp(tester);
      await signUp(tester);

      await tapText(tester, 'Use a different email');
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('an unverified account signs in to verification', (
      tester,
    ) async {
      await pumpApp(tester);
      await signUp(tester);
      await tapText(tester, 'Use a different email');

      await signIn(
        tester,
        email: 'ada@example.com',
        password: 'Analytical-Engine-1843',
      );
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });

  group('password recovery', () {
    Future<void> requestReset(WidgetTester tester) async {
      await tapText(tester, 'Forgot password?');
      await typeInto(tester, field('Email'), FakeAuthRepository.demoEmail);
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Send reset link'),
      );
    }

    Future<void> setNewPassword(WidgetTester tester) async {
      await typeInto(tester, field('New password'), newPassword);
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Update password'),
      );
    }

    testWidgets('appears on top of an open signed-in route', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');
      expect(find.byType(ChangePasswordScreen), findsOneWidget);

      await tapText(tester, 'Forgot it? Email a link');
      await tapText(tester, 'Open reset link');

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('Choose a new password'), findsOneWidget);
      // Visible on top, with the routes it covers still underneath.
      expect(find.byType(ChangePasswordScreen), findsNothing);
      expect(
        find.byType(ChangePasswordScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byType(SettingsScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
    });

    testWidgets('cancelling returns to the route underneath', (tester) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      fake.openRecoveryLink();
      await settleApp(tester);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);

      await tapFinder(tester, find.byTooltip('Cancel password reset'));
      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('finishing signed in stays where the user was', (tester) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      fake.openRecoveryLink();
      await settleApp(tester);

      await setNewPassword(tester);

      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Password updated.'), findsOneWidget);
      expect(fake.demoAccount!.password, newPassword);
    });

    testWidgets('survives the session ending underneath it', (tester) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Delete account');
      fake.openRecoveryLink();
      await settleApp(tester);
      await typeInto(tester, field('New password'), newPassword);

      fake.expireSession();
      await settleApp(tester);

      // The gate swapped underneath. The recovery screen and its text didn't.
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text(newPassword), findsOneWidget);
      expect(find.byType(SignInScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(SettingsScreen, skipOffstage: false), findsNothing);
      expect(find.byType(HomeScreen, skipOffstage: false), findsNothing);

      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Update password'),
      );
      expect(find.byType(SignInScreen), findsOneWidget);
      await signIn(tester, password: newPassword);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('opens over the splash while the session restores', (
      tester,
    ) async {
      final fake = await pumpApp(tester, settle: false);
      expect(find.byType(SplashScreen), findsOneWidget);

      fake.openRecoveryLink();
      await settleApp(tester);

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.byType(SplashScreen, skipOffstage: false), findsNothing);
      expect(find.byType(SignInScreen, skipOffstage: false), findsOneWidget);
    });

    testWidgets('the full signed-out flow ends on sign in', (tester) async {
      final fake = await pumpApp(tester);
      await requestReset(tester);
      expect(find.text('Check your inbox'), findsOneWidget);

      await tapText(tester, 'Open reset link');
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(
        find.byType(ForgotPasswordScreen, skipOffstage: false),
        findsOneWidget,
      );

      await setNewPassword(tester);

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(
        find.byType(ForgotPasswordScreen, skipOffstage: false),
        findsNothing,
      );
      expect(find.textContaining('Password updated'), findsOneWidget);
      final email = tester.widget<TextFormField>(field('Email'));
      expect(email.controller!.text, FakeAuthRepository.demoEmail);

      await signIn(tester);
      expect(find.textContaining('don\'t match'), findsOneWidget);
      await signIn(tester, password: newPassword);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(fake.demoAccount!.password, newPassword);
    });

    testWidgets('an unknown email looks the same as a known one', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapText(tester, 'Forgot password?');
      await typeInto(tester, field('Email'), 'nobody@example.com');
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Send reset link'),
      );

      expect(find.text('Check your inbox'), findsOneWidget);
      expect(find.textContaining('If an account exists'), findsOneWidget);
      expect(find.text('Open reset link'), findsNothing);
    });

    testWidgets('an expired link can be replaced from the reset screen', (
      tester,
    ) async {
      await pumpApp(tester);
      await requestReset(tester);
      await tapText(tester, 'Expire it');
      await tapText(tester, 'Open reset link');
      await setNewPassword(tester);

      expect(find.textContaining('expired or was already'), findsOneWidget);

      await tapText(tester, 'Send a new link');
      await tapText(tester, 'Open reset link');
      await setNewPassword(tester);

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.textContaining('Password updated'), findsOneWidget);
    });

    testWidgets('a newer link replaces the form and the older token', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await requestReset(tester);
      await tapText(tester, 'Open reset link');
      await typeInto(tester, field('New password'), 'typed-for-old-link-1');

      // Not awaited: the fake's delay only passes when the test pumps.
      fake.sendPasswordReset(email: FakeAuthRepository.demoEmail);
      await settleApp(tester);
      fake.openRecoveryLink();
      await settleApp(tester);

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('typed-for-old-link-1'), findsNothing);

      await setNewPassword(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.textContaining('Password updated'), findsOneWidget);
    });

    testWidgets('a network failure keeps the link usable', (tester) async {
      final fake = await pumpApp(tester);
      await requestReset(tester);
      await tapText(tester, 'Open reset link');
      fake.failNextRequest = true;
      await setNewPassword(tester);

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      await tapText(tester, 'Try again');
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });

  group('sign out and expiry', () {
    testWidgets('signing out from settings lands on sign in', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);

      await tapText(tester, 'Sign out');

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(SettingsScreen, skipOffstage: false), findsNothing);
      expect(find.byType(HomeScreen, skipOffstage: false), findsNothing);
      expect(find.text('You\'re signed out.'), findsOneWidget);

      // Back has nowhere signed-in to return to.
      await tester.binding.handlePopRoute();
      await settleApp(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('a failed sign out stays signed in and can be retried', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      fake.failNextRequest = true;

      await tapText(tester, 'Sign out');
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.textContaining('safe to retry'), findsOneWidget);

      await tapText(tester, 'Try again');
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('expiry on a pushed route closes it and explains why', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');

      fake.expireSession();
      await settleApp(tester);

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(
        find.byType(ChangePasswordScreen, skipOffstage: false),
        findsNothing,
      );
      expect(find.textContaining('session expired'), findsOneWidget);
      final email = tester.widget<TextFormField>(field('Email'));
      expect(email.controller!.text, FakeAuthRepository.demoEmail);
    });

    testWidgets('expiry found by a request ends the session the same way', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');
      fake.expireSession(notify: false);

      await typeInto(
        tester,
        field('Current password'),
        FakeAuthRepository.demoPassword,
      );
      await typeInto(tester, field('New password'), newPassword);
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Change password'),
      );

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.textContaining('session expired'), findsOneWidget);
    });

    testWidgets('a notice clears when moving on to another screen', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signUp(tester);
      await tester.enterText(codeField, fake.verificationEmail!.code!);
      await settleApp(tester);
      expect(find.textContaining('Email verified'), findsOneWidget);

      await openSettings(tester);
      expect(find.textContaining('Email verified'), findsNothing);
    });

    testWidgets('an expired user\'s email is not offered after the next '
        'sign out', (tester) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      fake.expireSession();
      await settleApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Sign out');

      final email = tester.widget<TextFormField>(field('Email'));
      expect(email.controller!.text, isEmpty);
    });

    testWidgets('signing in again starts from home', (tester) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      fake.expireSession();
      await settleApp(tester);

      await signIn(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SettingsScreen, skipOffstage: false), findsNothing);
      expect(find.textContaining('session expired'), findsNothing);
    });
  });

  group('account settings', () {
    testWidgets('change password rejects the wrong current password', (
      tester,
    ) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');

      await typeInto(tester, field('Current password'), 'wrong-password');
      await typeInto(tester, field('New password'), newPassword);
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Change password'),
      );

      expect(find.byType(ChangePasswordScreen), findsOneWidget);
      expect(find.text('That password isn\'t right.'), findsOneWidget);
      expect(fake.demoAccount!.password, FakeAuthRepository.demoPassword);
    });

    testWidgets('change password works, and the demo card keeps up', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');

      await typeInto(
        tester,
        field('Current password'),
        FakeAuthRepository.demoPassword,
      );
      await typeInto(tester, field('New password'), newPassword);
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Change password'),
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Password changed.'), findsOneWidget);

      await tapText(tester, 'Sign out');
      expect(find.text(newPassword), findsOneWidget);
      expect(find.text(FakeAuthRepository.demoPassword), findsNothing);
    });

    testWidgets('delete needs the password, then the account is gone', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Delete account');

      await typeInto(tester, field('Password'), 'wrong-password');
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Delete my account'),
      );
      expect(find.text('That password isn\'t right.'), findsOneWidget);

      await typeInto(
        tester,
        field('Password'),
        FakeAuthRepository.demoPassword,
      );
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Delete my account'),
      );

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text('Your account was deleted.'), findsOneWidget);

      await signIn(tester);
      expect(find.textContaining('don\'t match'), findsOneWidget);

      // The demo can't dead-end.
      await tapText(tester, 'Restore demo account');
      await signIn(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('theme preference applies and outlives the session', (
      tester,
    ) async {
      Brightness current(Type screen) =>
          Theme.of(tester.element(find.byType(screen))).colorScheme.brightness;

      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      expect(current(SettingsScreen), Brightness.light);

      await tapText(tester, 'Dark');
      expect(current(SettingsScreen), Brightness.dark);

      await tapText(tester, 'Sign out');
      expect(current(SignInScreen), Brightness.dark);
    });

    testWidgets('System follows the host theme', (tester) async {
      await pumpApp(tester, brightness: Brightness.dark);
      final scheme = Theme.of(
        tester.element(find.byType(SignInScreen)),
      ).colorScheme;
      expect(scheme.brightness, Brightness.dark);
    });
  });

  group('navigation', () {
    testWidgets('system back pops the nested route, and state follows', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');

      await tester.binding.handlePopRoute();
      await settleApp(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settleApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Reopening works, which it wouldn't if the stack still listed it.
      await openSettings(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('system back cancels recovery', (tester) async {
      final fake = await pumpApp(tester);
      await signIn(tester);
      fake.openRecoveryLink();
      await settleApp(tester);

      await tester.binding.handlePopRoute();
      await settleApp(tester);
      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);

      fake.openRecoveryLink();
      await settleApp(tester);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });
  });

  group('keyboard', () {
    bool isFocused(WidgetTester tester, String label) => tester
        .widget<EditableText>(
          find.descendant(
            of: field(label),
            matching: find.byType(EditableText),
          ),
        )
        .focusNode
        .hasFocus;

    testWidgets('sign in: next moves on, done submits', (tester) async {
      await pumpApp(tester);
      await tester.showKeyboard(field('Email'));
      tester.testTextInput.enterText(FakeAuthRepository.demoEmail);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(isFocused(tester, 'Password'), isTrue);

      tester.testTextInput.enterText(FakeAuthRepository.demoPassword);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settleApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('next skips the show password button', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await openSettings(tester);
      await tapText(tester, 'Change password');

      await tester.showKeyboard(field('Current password'));
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(isFocused(tester, 'New password'), isTrue);
    });

    testWidgets('a failed validation focuses the first bad field', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapText(tester, 'Create an account');
      await typeInto(tester, field('Name'), 'Ada');
      await tapFinder(
        tester,
        find.widgetWithText(FilledButton, 'Create account'),
      );
      expect(isFocused(tester, 'Email'), isTrue);
    });

    testWidgets('fields declare autofill hints and input actions', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapText(tester, 'Create an account');

      EditableText editable(String label) => tester.widget<EditableText>(
        find.descendant(of: field(label), matching: find.byType(EditableText)),
      );

      expect(editable('Name').autofillHints, [AutofillHints.name]);
      expect(editable('Email').autofillHints, [AutofillHints.email]);
      expect(editable('Password').autofillHints, [AutofillHints.newPassword]);
      expect(editable('Name').textInputAction, TextInputAction.next);
      expect(editable('Password').textInputAction, TextInputAction.done);
    });
  });
}

class _CountingRepository extends FakeAuthRepository {
  _CountingRepository() : super(latency: const Duration(milliseconds: 20));

  int signInCalls = 0;

  @override
  Future<void> signIn({required String email, required String password}) {
    signInCalls++;
    return super.signIn(email: email, password: password);
  }
}
