import 'dart:async';

import 'package:core/templates/banking_wallet/data/in_memory_wallet_repository.dart';
import 'package:core/templates/banking_wallet/data/seed_data.dart';
import 'package:core/templates/banking_wallet/models/account.dart';
import 'package:core/templates/banking_wallet/models/bank_card.dart';
import 'package:core/templates/banking_wallet/models/payee.dart';
import 'package:core/templates/banking_wallet/models/transaction.dart';
import 'package:core/templates/banking_wallet/models/transfer.dart';
import 'package:core/templates/banking_wallet/screens/lock_screen.dart';
import 'package:core/templates/banking_wallet/screens/send/review_screen.dart';
import 'package:core/templates/banking_wallet/state/wallet_controller.dart';
import 'package:core/templates/banking_wallet/state/wallet_scope.dart';
import 'package:core/templates/banking_wallet/widgets/slide_to_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _amount = 1234;
const _sentLabel = r'$12.34 sent';
final Payee _payee = seedPayees.first;

/// The in-memory bank with switches for each way a real one can fail.
class FailingWalletRepository extends InMemoryWalletRepository {
  FailingWalletRepository() : super(latency: Duration.zero);

  bool failRefresh = false;
  bool loseNextResponse = false;
  bool hangNextSend = false;
  bool hangNextPinCheck = false;
  int failNextPinChecks = 0;
  int pinChecks = 0;
  String? rejectNextWith;
  final Set<String> refusedCards = {};
  final Map<String, Completer<void>> cardGates = {};
  final List<TransferRequest> requests = [];

  @override
  Future<bool> verifyPin(String pin) async {
    pinChecks++;
    if (hangNextPinCheck) {
      hangNextPinCheck = false;
      return Completer<bool>().future;
    }
    if (failNextPinChecks > 0) {
      failNextPinChecks--;
      throw StateError('network down');
    }
    return super.verifyPin(pin);
  }

  @override
  Future<List<Account>> fetchAccounts() async {
    if (failRefresh) throw StateError('refresh failed');
    return super.fetchAccounts();
  }

  @override
  Future<Transaction> sendMoney(TransferRequest request) async {
    requests.add(request);
    if (hangNextSend) {
      hangNextSend = false;
      return Completer<Transaction>().future;
    }
    final rejection = rejectNextWith;
    if (rejection != null) {
      rejectNextWith = null;
      throw TransferException(rejection);
    }
    final debit = await super.sendMoney(request);
    if (loseNextResponse) {
      loseNextResponse = false;
      throw TimeoutException('The response was lost');
    }
    return debit;
  }

  @override
  Future<BankCard> setCardFrozen(String cardId, {required bool frozen}) async {
    await cardGates[cardId]?.future;
    if (refusedCards.contains(cardId)) throw StateError('refused');
    return super.setCardFrozen(cardId, frozen: frozen);
  }
}

class _Harness {
  _Harness(this.repository, this.controller, this.navigator);

  final FailingWalletRepository repository;
  final WalletController controller;
  final GlobalKey<NavigatorState> navigator;

  int get balance => controller.accountById(checkingId)!.balanceCents;

  /// What the bank holds, read past any refresh failure. The fake answers on
  /// a timer, so the test clock has to move.
  Future<int> bankBalance(WidgetTester tester) async {
    final saved = repository.failRefresh;
    repository.failRefresh = false;
    final accounts = repository.fetchAccounts();
    repository.failRefresh = saved;
    await tester.pump(const Duration(milliseconds: 1));
    return (await accounts).firstWhere((a) => a.id == checkingId).balanceCents;
  }

  void openReview({Payee? payee}) {
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewScreen(
          payee: payee ?? _payee,
          fromAccountId: checkingId,
          amountCents: _amount,
        ),
      ),
    );
  }
}

Future<_Harness> _pumpWallet(
  WidgetTester tester,
  FailingWalletRepository repository,
) async {
  final controller = WalletController(repository);
  final navigator = GlobalKey<NavigatorState>();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    WalletScope(
      controller: controller,
      child: MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: Text('Home')),
      ),
    ),
  );
  unawaited(controller.load());
  await tester.pumpAndSettle();
  return _Harness(repository, controller, navigator);
}

Future<_Harness> _pumpReview(
  WidgetTester tester,
  FailingWalletRepository repository,
) async {
  final harness = await _pumpWallet(tester, repository);
  harness.openReview();
  await tester.pumpAndSettle();
  return harness;
}

Future<WalletController> _pumpLock(
  WidgetTester tester,
  FailingWalletRepository repository,
) async {
  final controller = WalletController(repository);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    WalletScope(
      controller: controller,
      child: const MaterialApp(home: LockScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pumpAndSettle();
}

const _pinError = "Couldn't check your PIN. Check your connection.";

Future<void> _slide(WidgetTester tester) async {
  tester.widget<SlideToConfirm>(find.byType(SlideToConfirm)).onConfirmed();
  await tester.pumpAndSettle();
}

void main() {
  const startingBalance = 421836;

  group('PIN checks that fail', () {
    testWidgets('show a message and retry the same PIN', (tester) async {
      final repository = FailingWalletRepository()..failNextPinChecks = 1;
      final controller = await _pumpLock(tester, repository);

      await _enterPin(tester, '2580');

      expect(tester.takeException(), isNull);
      expect(find.text(_pinError), findsOneWidget);
      expect(controller.isUnlocked, isFalse);

      await tester.tap(find.text('Try again'));
      await tester.pump(const Duration(milliseconds: 1));

      expect(repository.pinChecks, 2);
      expect(controller.isUnlocked, isTrue);
    });

    testWidgets('leave the keypad working', (tester) async {
      final repository = FailingWalletRepository()..failNextPinChecks = 1;
      final controller = await _pumpLock(tester, repository);
      await _enterPin(tester, '1111');

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(find.text(_pinError), findsNothing);
      expect(find.text('Try again'), findsNothing);

      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(repository.pinChecks, 2);
      expect(controller.failedPinAttempts, 1);
      expect(find.textContaining('Wrong PIN'), findsOneWidget);
    });

    testWidgets('do not count as wrong PINs', (tester) async {
      final repository = FailingWalletRepository()
        ..failNextPinChecks = WalletController.maxPinAttempts + 1;
      final controller = await _pumpLock(tester, repository);

      await _enterPin(tester, '1111');
      for (var i = 0; i < WalletController.maxPinAttempts; i++) {
        await tester.tap(find.text('Try again'));
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      }

      expect(repository.pinChecks, WalletController.maxPinAttempts + 1);
      expect(controller.failedPinAttempts, 0);
      expect(controller.pinLockedUntil, isNull);
      expect(find.textContaining('Wrong PIN'), findsNothing);
      expect(find.text(_pinError), findsOneWidget);
    });

    testWidgets('that hang time out and free the keypad', (tester) async {
      final repository = FailingWalletRepository()..hangNextPinCheck = true;
      final controller = await _pumpLock(tester, repository);

      await _enterPin(tester, '2580');
      expect(find.text(_pinError), findsNothing);

      await tester.pump(WalletController.pinCheckTimeout);
      await tester.pump();

      expect(find.text(_pinError), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pump(const Duration(milliseconds: 1));
      expect(controller.isUnlocked, isTrue);
    });

    test('report unavailable and never throw', () async {
      final repository = FailingWalletRepository()..failNextPinChecks = 1;
      final controller = WalletController(repository);
      addTearDown(controller.dispose);

      expect(await controller.submitPin('2580'), PinResult.unavailable);
      expect(controller.failedPinAttempts, 0);
      expect(await controller.submitPin('2580'), PinResult.correct);
    });
  });

  group('commit and refresh are separate outcomes', () {
    testWidgets('a failed refresh after a commit still shows success', (
      tester,
    ) async {
      final repository = FailingWalletRepository();
      final harness = await _pumpReview(tester, repository);
      repository.failRefresh = true;

      await _slide(tester);

      expect(find.text(_sentLabel), findsOneWidget);
      expect(find.textContaining('out of date'), findsOneWidget);
      expect(find.textContaining('has not moved'), findsNothing);
      expect(find.byType(SlideToConfirm), findsNothing);
      expect(await harness.bankBalance(tester), startingBalance - _amount);
    });

    testWidgets('the success screen shows the debit without fresh data', (
      tester,
    ) async {
      final repository = FailingWalletRepository();
      final harness = await _pumpReview(tester, repository);
      repository.failRefresh = true;

      await _slide(tester);
      expect(harness.balance, startingBalance - _amount);

      await tester.tap(find.text('View receipt'));
      await tester.pumpAndSettle();
      expect(find.text('Transaction not found'), findsNothing);
    });

    testWidgets('a transfer between own accounts credits the destination', (
      tester,
    ) async {
      final repository = FailingWalletRepository();
      final harness = await _pumpWallet(tester, repository);
      final savings = harness.controller.accountById(savingsId)!.balanceCents;
      final own = harness.controller.ownAccountPayees.firstWhere(
        (payee) => payee.ownAccountId == savingsId,
      );
      harness.openReview(payee: own);
      await tester.pumpAndSettle();
      repository.failRefresh = true;

      await _slide(tester);

      expect(find.text(_sentLabel), findsOneWidget);
      expect(
        harness.controller.accountById(savingsId)!.balanceCents,
        savings + _amount,
      );
    });

    testWidgets('the stale notice clears once a refresh works', (tester) async {
      final repository = FailingWalletRepository();
      await _pumpReview(tester, repository);
      repository.failRefresh = true;
      await _slide(tester);

      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();
      expect(find.textContaining('out of date'), findsOneWidget);

      repository.failRefresh = false;
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();
      expect(find.textContaining('out of date'), findsNothing);
      expect(find.text(_sentLabel), findsOneWidget);
    });

    testWidgets('a clean transfer shows no stale notice', (tester) async {
      await _pumpReview(tester, FailingWalletRepository());
      await _slide(tester);
      expect(find.text(_sentLabel), findsOneWidget);
      expect(find.textContaining('out of date'), findsNothing);
    });
  });

  group('unknown outcomes', () {
    testWidgets('a lost response never claims the money did not move', (
      tester,
    ) async {
      final repository = FailingWalletRepository()..loseNextResponse = true;
      await _pumpReview(tester, repository);

      await _slide(tester);

      expect(find.textContaining('has not moved'), findsNothing);
      expect(find.textContaining('may have gone through'), findsOneWidget);
      expect(find.text(_sentLabel), findsNothing);
    });

    testWidgets('retrying a lost response reuses the key and pays once', (
      tester,
    ) async {
      final repository = FailingWalletRepository()..loseNextResponse = true;
      final harness = await _pumpReview(tester, repository);

      await _slide(tester);
      await _slide(tester);

      expect(find.text(_sentLabel), findsOneWidget);
      expect(repository.requests, hasLength(2));
      expect(repository.requests.first.idempotencyKey, isNotEmpty);
      expect(
        repository.requests.last.idempotencyKey,
        repository.requests.first.idempotencyKey,
      );
      expect(await harness.bankBalance(tester), startingBalance - _amount);
    });

    testWidgets('a retry replayed while refresh fails is not applied twice', (
      tester,
    ) async {
      final repository = FailingWalletRepository()..loseNextResponse = true;
      final harness = await _pumpReview(tester, repository);

      await _slide(tester);
      repository.failRefresh = true;
      await _slide(tester);

      expect(find.text(_sentLabel), findsOneWidget);
      expect(harness.balance, startingBalance - _amount);
    });

    testWidgets('leaving the screen and coming back keeps the key', (
      tester,
    ) async {
      final repository = FailingWalletRepository()..loseNextResponse = true;
      final harness = await _pumpReview(tester, repository);
      await _slide(tester);

      harness.navigator.currentState!.pop();
      await tester.pumpAndSettle();
      harness.openReview();
      await tester.pumpAndSettle();
      expect(find.textContaining('may have gone through'), findsOneWidget);

      await _slide(tester);

      expect(find.text(_sentLabel), findsOneWidget);
      expect(
        repository.requests.last.idempotencyKey,
        repository.requests.first.idempotencyKey,
      );
      expect(await harness.bankBalance(tester), startingBalance - _amount);
    });

    testWidgets('the note is locked so a retry matches the first try', (
      tester,
    ) async {
      final repository = FailingWalletRepository()..loseNextResponse = true;
      await _pumpReview(tester, repository);
      await tester.enterText(find.byType(TextField), 'Rent');

      await _slide(tester);

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('a send with no answer times out as unknown', (tester) async {
      final repository = FailingWalletRepository()..hangNextSend = true;
      await _pumpReview(tester, repository);

      tester.widget<SlideToConfirm>(find.byType(SlideToConfirm)).onConfirmed();
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();

      expect(find.textContaining('may have gone through'), findsOneWidget);
    });
  });

  group('rejections', () {
    testWidgets('show the bank message and start a new attempt', (
      tester,
    ) async {
      final repository = FailingWalletRepository()
        ..rejectNextWith = 'Not enough money in this account.';
      final harness = await _pumpReview(tester, repository);

      await _slide(tester);
      expect(find.text('Not enough money in this account.'), findsOneWidget);
      expect(find.textContaining('may have gone through'), findsNothing);
      expect(await harness.bankBalance(tester), startingBalance);

      await _slide(tester);
      expect(find.text(_sentLabel), findsOneWidget);
      expect(
        repository.requests.last.idempotencyKey,
        isNot(repository.requests.first.idempotencyKey),
      );
    });
  });

  group('InMemoryWalletRepository idempotency', () {
    TransferRequest request(String key, {int amountCents = _amount}) {
      return TransferRequest(
        idempotencyKey: key,
        fromAccountId: checkingId,
        payee: _payee,
        amountCents: amountCents,
      );
    }

    Future<int> balance(InMemoryWalletRepository repository) async {
      final accounts = await repository.fetchAccounts();
      return accounts.firstWhere((a) => a.id == checkingId).balanceCents;
    }

    test('a repeated key returns the original debit', () async {
      final repository = InMemoryWalletRepository(latency: Duration.zero);
      final first = await repository.sendMoney(request('a'));
      final second = await repository.sendMoney(request('a'));
      expect(second.id, first.id);
      expect(await balance(repository), startingBalance - _amount);
    });

    test('concurrent sends with one key pay once', () async {
      final repository = InMemoryWalletRepository(latency: Duration.zero);
      await Future.wait([
        repository.sendMoney(request('a')),
        repository.sendMoney(request('a')),
      ]);
      expect(await balance(repository), startingBalance - _amount);
    });

    test('a replay succeeds even if the balance no longer covers it', () async {
      final repository = InMemoryWalletRepository(latency: Duration.zero);
      const everything = 400000;
      final first = await repository.sendMoney(
        request('a', amountCents: everything),
      );
      final second = await repository.sendMoney(
        request('a', amountCents: everything),
      );
      expect(second.id, first.id);
    });

    test('a new key is a new transfer', () async {
      final repository = InMemoryWalletRepository(latency: Duration.zero);
      await repository.sendMoney(request('a'));
      await repository.sendMoney(request('b'));
      expect(await balance(repository), startingBalance - _amount * 2);
    });

    test('a repeated key with other details is rejected', () async {
      final repository = InMemoryWalletRepository(latency: Duration.zero);
      await repository.sendMoney(request('a'));
      await expectLater(
        repository.sendMoney(request('a', amountCents: _amount + 1)),
        throwsA(isA<TransferException>()),
      );
      expect(await balance(repository), startingBalance - _amount);
    });

    test('generated keys differ', () {
      expect(generateIdempotencyKey(), isNot(generateIdempotencyKey()));
      expect(generateIdempotencyKey(), hasLength(32));
    });
  });

  group('card freeze rollback', () {
    Future<WalletController> loaded(FailingWalletRepository repository) async {
      final controller = WalletController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      return controller;
    }

    test('a failed freeze keeps another card that froze meanwhile', () async {
      final repository = FailingWalletRepository()
        ..refusedCards.add(debitCardId)
        ..cardGates[debitCardId] = Completer<void>();
      final controller = await loaded(repository);

      final failing = controller.setCardFrozen(debitCardId, frozen: true);
      await controller.setCardFrozen(virtualCardId, frozen: true);
      repository.cardGates[debitCardId]!.complete();
      await expectLater(failing, throwsStateError);

      expect(controller.cardById(debitCardId)!.isFrozen, isFalse);
      expect(controller.cardById(virtualCardId)!.isFrozen, isTrue);
    });

    test('a failed freeze keeps a card still in flight', () async {
      final repository = FailingWalletRepository()
        ..refusedCards.add(debitCardId)
        ..cardGates[debitCardId] = Completer<void>()
        ..cardGates[virtualCardId] = Completer<void>();
      final controller = await loaded(repository);

      final failing = controller.setCardFrozen(debitCardId, frozen: true);
      final working = controller.setCardFrozen(virtualCardId, frozen: true);
      repository.cardGates[debitCardId]!.complete();
      await expectLater(failing, throwsStateError);
      expect(controller.cardById(virtualCardId)!.isFrozen, isTrue);

      repository.cardGates[virtualCardId]!.complete();
      await working;
      expect(controller.cardById(virtualCardId)!.isFrozen, isTrue);
    });

    test('a failed unfreeze restores the frozen state', () async {
      final repository = FailingWalletRepository();
      final controller = await loaded(repository);
      await controller.setCardFrozen(debitCardId, frozen: true);

      repository.refusedCards.add(debitCardId);
      await expectLater(
        controller.setCardFrozen(debitCardId, frozen: false),
        throwsStateError,
      );

      expect(controller.cardById(debitCardId)!.isFrozen, isTrue);
      expect(controller.isCardUpdating(debitCardId), isFalse);
    });
  });

  group('SlideToConfirm keyboard access', () {
    Future<List<int>> pumpSlider(
      WidgetTester tester, {
      bool busy = false,
      Map<ShortcutActivator, Intent>? shortcuts,
    }) async {
      final calls = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          shortcuts: shortcuts,
          home: Scaffold(
            body: Column(
              children: [
                const TextField(),
                SlideToConfirm(
                  label: 'Slide to send',
                  busy: busy,
                  onConfirmed: () => calls.add(1),
                ),
              ],
            ),
          ),
        ),
      );
      return calls;
    }

    Future<void> tabToSlider(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }

    for (final (name, key) in [
      ('Enter', LogicalKeyboardKey.enter),
      ('numpad Enter', LogicalKeyboardKey.numpadEnter),
      ('Space', LogicalKeyboardKey.space),
    ]) {
      testWidgets('Tab then $name confirms once', (tester) async {
        final calls = await pumpSlider(tester);
        await tabToSlider(tester);
        await tester.sendKeyEvent(key);
        await tester.pump(const Duration(milliseconds: 300));
        expect(calls, hasLength(1));
      });
    }

    testWidgets('works without the default shortcuts', (tester) async {
      final calls = await pumpSlider(
        tester,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
        },
      );
      await tabToSlider(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, hasLength(1));
    });

    testWidgets('a held key confirms once', (tester) async {
      final calls = await pumpSlider(tester);
      await tabToSlider(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, hasLength(1));
    });

    testWidgets('does nothing while busy', (tester) async {
      final calls = await pumpSlider(tester, busy: true);
      await tabToSlider(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, isEmpty);
    });

    testWidgets('other keys pass through', (tester) async {
      final calls = await pumpSlider(tester);
      await tabToSlider(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(calls, isEmpty);
    });

    testWidgets('semantics expose a focusable, tappable button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSlider(tester);
      await tabToSlider(tester);
      expect(
        tester.getSemantics(find.byType(SlideToConfirm)),
        isSemantics(
          label: 'Slide to send',
          isButton: true,
          isFocusable: true,
          isFocused: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('semantics report busy as disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSlider(tester, busy: true);
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(SlideToConfirm)),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('the review screen sends from the keyboard', (tester) async {
      final repository = FailingWalletRepository();
      await _pumpReview(tester, repository);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text(_sentLabel), findsOneWidget);
      expect(repository.requests, hasLength(1));
    });
  });
}
