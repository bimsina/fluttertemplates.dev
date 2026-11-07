import 'dart:async';

import 'package:core/templates/auth_flow/data/fake_auth_repository.dart';
import 'package:core/templates/auth_flow/models/auth_event.dart';
import 'package:core/templates/auth_flow/screens/home_screen.dart';
import 'package:core/templates/auth_flow/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

/// Forwards the fake's events and can add errors to them, as a provider's auth
/// stream does when a token refresh fails.
class FailingEventsRepository extends FakeAuthRepository {
  FailingEventsRepository({super.latency = Duration.zero});

  final _output = StreamController<AuthEvent>.broadcast();
  StreamSubscription<AuthEvent>? _forwarding;

  @override
  Stream<AuthEvent> get events {
    _forwarding ??= super.events.listen(_output.add);
    return _output.stream;
  }

  void failStream() => _output.addError(StateError('provider offline'));

  @override
  void dispose() {
    _forwarding?.cancel();
    _output.close();
    super.dispose();
  }
}

Future<(AuthController, FailingEventsRepository)> started() async {
  final repository = FailingEventsRepository();
  final auth = AuthController(repository)..start();
  addTearDown(() {
    auth.dispose();
    repository.dispose();
  });
  await pumpEventQueue();
  return (auth, repository);
}

Future<void> signIn(AuthController auth) async {
  await auth.signIn(
    email: FakeAuthRepository.demoEmail,
    password: FakeAuthRepository.demoPassword,
  );
  await pumpEventQueue();
}

void main() {
  test('a stream error keeps the user signed in and warns', () async {
    final (auth, repository) = await started();
    await signIn(auth);
    final user = auth.user;
    expect(auth.status, AuthStatus.signedIn);

    repository.failStream();
    await pumpEventQueue();

    expect(auth.status, AuthStatus.signedIn);
    expect(auth.user, same(user));
    expect(auth.notice?.tone, NoticeTone.warning);
    expect(auth.notice?.message, contains('still signed in'));
  });

  test('a stream error while signed out stays signed out', () async {
    final (auth, repository) = await started();
    expect(auth.status, AuthStatus.signedOut);

    repository.failStream();
    await pumpEventQueue();

    expect(auth.status, AuthStatus.signedOut);
    expect(auth.notice?.tone, NoticeTone.warning);
    expect(auth.notice?.message, isNot(contains('signed in')));
  });

  test('a stream error doesn\'t close an open recovery', () async {
    final (auth, repository) = await started();
    await auth.sendPasswordReset(FakeAuthRepository.demoEmail);
    repository.openRecoveryLink();
    await pumpEventQueue();
    final recovery = auth.recovery;
    expect(recovery, isNotNull);

    repository.failStream();
    await pumpEventQueue();

    expect(auth.recovery, same(recovery));
  });

  test('events after an error still work', () async {
    final (auth, repository) = await started();
    await signIn(auth);
    repository.failStream();
    await pumpEventQueue();

    await auth.signOut();
    await pumpEventQueue();

    expect(auth.status, AuthStatus.signedOut);
  });

  test('an error during restore doesn\'t end the restore', () async {
    final repository = FailingEventsRepository();
    final auth = AuthController(repository);
    addTearDown(() {
      auth.dispose();
      repository.dispose();
    });

    auth.start();
    repository.failStream();
    await pumpEventQueue();

    expect(auth.status, AuthStatus.signedOut);
    expect(auth.restoreFailure, isNull);
  });

  testWidgets('the notice shows above the signed-in home', (tester) async {
    final repository = FailingEventsRepository(
      latency: const Duration(milliseconds: 20),
    );
    await pumpApp(tester, repository: repository);
    await tester.enterText(field('Email'), FakeAuthRepository.demoEmail);
    await tester.enterText(field('Password'), FakeAuthRepository.demoPassword);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await settleApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    repository.failStream();
    await settleApp(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('still signed in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
