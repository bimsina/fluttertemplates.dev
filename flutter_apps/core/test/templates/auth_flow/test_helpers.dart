import 'package:core/templates/auth_flow/app.dart';
import 'package:core/templates/auth_flow/data/fake_auth_repository.dart';
import 'package:core/templates/auth_flow/widgets/code_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const phone = Size(375, 700);

/// Pumps the app under a host `MaterialApp`, and returns its fake backend.
///
/// With [settle] false the test starts while the session is being restored.
Future<FakeAuthRepository> pumpApp(
  WidgetTester tester, {
  Size size = phone,
  double textScale = 1,
  Brightness brightness = Brightness.light,
  bool settle = true,
  FakeAuthRepository? repository,
}) async {
  WidgetController.hitTestWarningShouldBeFatal = true;
  final fake =
      repository ??
      FakeAuthRepository(latency: const Duration(milliseconds: 20));
  addTearDown(fake.dispose);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: AuthFlowApp(repository: fake),
    ),
  );
  if (settle) await settleApp(tester);
  return fake;
}

/// Runs out the fake's latency and any route transition. `pumpAndSettle` can't
/// be used in general: a spinner never stops scheduling frames.
Future<void> settleApp(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

final Finder codeField = find.descendant(
  of: find.byType(CodeInput),
  matching: find.byType(TextField),
);

Future<void> tapText(WidgetTester tester, String text) async {
  await tapFinder(tester, find.text(text));
}

Future<void> tapFinder(WidgetTester tester, Finder finder) async {
  // Focusing a field starts a short scroll, and scrollables ignore pointers
  // until it ends.
  await tester.pump(const Duration(milliseconds: 200));
  if (finder.evaluate().isEmpty) {
    // Not built yet: further down a lazy list.
    await tester.scrollUntilVisible(
      finder,
      120,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(finder.first);
  await settleApp(tester);
}

Future<void> typeInto(WidgetTester tester, Finder finder, String text) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.enterText(finder, text);
  await tester.pump();
}

Future<void> signIn(
  WidgetTester tester, {
  String email = FakeAuthRepository.demoEmail,
  String password = FakeAuthRepository.demoPassword,
}) async {
  await typeInto(tester, field('Email'), email);
  await typeInto(tester, field('Password'), password);
  await tapFinder(tester, find.widgetWithText(FilledButton, 'Sign in'));
}

Future<void> openSettings(WidgetTester tester) async {
  await tapFinder(tester, find.byTooltip('Account settings'));
}

/// Fills in the sign-up form and submits it, from the sign-in screen.
Future<void> signUp(
  WidgetTester tester, {
  String email = 'ada@example.com',
  String password = 'Analytical-Engine-1843',
}) async {
  await tapText(tester, 'Create an account');
  await typeInto(tester, field('Name'), 'Ada Lovelace');
  await typeInto(tester, field('Email'), email);
  await typeInto(tester, field('Password'), password);
  await tapFinder(tester, find.widgetWithText(FilledButton, 'Create account'));
}
