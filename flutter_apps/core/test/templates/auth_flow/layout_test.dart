import 'package:core/templates/auth_flow/data/fake_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

/// Any overflow is reported as a test failure, so each case passes by reaching
/// every screen and showing its longest state without one.
typedef Walk = Future<void> Function(WidgetTester, FakeAuthRepository);

Future<void> signedOutScreens(WidgetTester t, FakeAuthRepository fake) async {
  // Sign in with an error showing.
  await signIn(t, password: 'wrong-password');
  // Sign up with a validation error on every field.
  await tapText(t, 'Create an account');
  await tapFinder(t, find.widgetWithText(FilledButton, 'Create account'));
  await typeInto(t, field('Password'), 'weak');
  await t.pump();
  await tapFinder(t, find.byTooltip('Back to sign in'));
  // Forgot password, sent state, the reset form over it, and its expired state.
  await tapText(t, 'Forgot password?');
  await typeInto(t, field('Email'), FakeAuthRepository.demoEmail);
  await tapFinder(t, find.widgetWithText(FilledButton, 'Send reset link'));
  await tapText(t, 'Expire it');
  await tapText(t, 'Open reset link');
  await typeInto(t, field('New password'), 'Analytical-Engine-1843');
  await tapFinder(t, find.widgetWithText(FilledButton, 'Update password'));
  await tapText(t, 'Send a new link');
  await tapFinder(t, find.byTooltip('Cancel password reset'));
}

Future<void> verifyScreen(WidgetTester t, FakeAuthRepository fake) async {
  await signUp(
    t,
    email: 'a.very.long.address.for.layout@subdomain.example.com',
  );
  await t.enterText(codeField, '12');
  await t.pump();
  await tapText(t, 'Expire it');
  await t.enterText(codeField, fake.verificationEmail!.code!);
  await settleApp(t);
}

Future<void> signedInScreens(WidgetTester t, FakeAuthRepository fake) async {
  await signIn(t);
  await openSettings(t);
  await tapText(t, 'Change password');
  await tapText(t, 'Forgot it? Email a link');
  await tapFinder(t, find.widgetWithText(FilledButton, 'Change password'));
  await tapFinder(t, find.byTooltip('Back'));
  await tapText(t, 'Delete account');
  await tapFinder(t, find.widgetWithText(FilledButton, 'Delete my account'));
  await tapFinder(t, find.byTooltip('Back'));
  await tapText(t, 'Dark');
  await tapText(t, 'Light');
  fake.failNextRequest = true;
  await tapText(t, 'Sign out');
  fake.expireSession();
  await settleApp(t);
}

void main() {
  const sizes = {
    '320 wide, 200% text': (Size(320, 568), 2.0),
    '320 wide, tall, 200% text': (Size(320, 700), 2.0),
    'demo iframe': (phone, 1.0),
    'demo iframe, 200% text': (phone, 2.0),
    '1024x768': (Size(1024, 768), 1.0),
    '1024x768, 200% text': (Size(1024, 768), 2.0),
  };
  const walks = <String, Walk>{
    'signed-out screens': signedOutScreens,
    'verify screen': verifyScreen,
    'signed-in screens': signedInScreens,
  };

  for (final MapEntry(key: sizeName, value: (size, scale)) in sizes.entries) {
    for (final brightness in Brightness.values) {
      for (final MapEntry(key: walkName, value: walk) in walks.entries) {
        testWidgets('$walkName at $sizeName, ${brightness.name}', (t) async {
          final fake = await pumpApp(
            t,
            size: size,
            textScale: scale,
            brightness: brightness,
          );
          await walk(t, fake);
        });
      }
    }

    testWidgets('splash with a restore failure at $sizeName', (t) async {
      final fake = FakeAuthRepository(latency: const Duration(milliseconds: 20))
        ..failNextRequest = true;
      await pumpApp(t, size: size, textScale: scale, repository: fake);
      expect(find.text('Try again'), findsOneWidget);
    });
  }

  group('accessibility guidelines', () {
    for (final brightness in Brightness.values) {
      testWidgets('sign in and home, ${brightness.name}', (t) async {
        final handle = t.ensureSemantics();
        await pumpApp(t, brightness: brightness);

        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));

        await signIn(t);
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));

        await openSettings(t);
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    testWidgets('icon-only buttons are labelled', (t) async {
      await pumpApp(t);
      expect(find.byTooltip('Show password'), findsOneWidget);
      await tapFinder(t, find.byTooltip('Show password'));
      expect(find.byTooltip('Hide password'), findsOneWidget);

      await signIn(t);
      expect(find.byTooltip('Account settings'), findsOneWidget);
      await openSettings(t);
      expect(find.byTooltip('Back'), findsOneWidget);
    });
  });
}
