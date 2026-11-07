import 'dart:async';

import 'package:core/templates/banking_wallet/data/in_memory_wallet_repository.dart';
import 'package:core/templates/banking_wallet/models/bank_card.dart';
import 'package:core/templates/banking_wallet/models/payee.dart';
import 'package:core/templates/banking_wallet/screens/send/add_recipient_screen.dart';
import 'package:core/templates/banking_wallet/state/wallet_controller.dart';
import 'package:core/templates/banking_wallet/state/wallet_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The in-memory bank with switches for payee and card failures.
class FaultyWalletRepository extends InMemoryWalletRepository {
  FaultyWalletRepository() : super(latency: Duration.zero);

  bool losePayeeResponse = false;
  bool dropPayee = false;
  bool hangPayee = false;
  String? rejectPayeeWith;
  bool failPayeeReads = false;
  bool hangPayeeReads = false;

  bool loseCardResponse = false;
  bool refuseCard = false;
  bool hangCard = false;
  bool failCardReads = false;

  final payeeKeys = <String>[];

  @override
  Future<Payee> addPayee(AddPayeeRequest request) async {
    payeeKeys.add(request.idempotencyKey);
    if (hangPayee) {
      hangPayee = false;
      return Completer<Payee>().future;
    }
    if (dropPayee) {
      dropPayee = false;
      throw TimeoutException('Never arrived');
    }
    final rejection = rejectPayeeWith;
    if (rejection != null) {
      rejectPayeeWith = null;
      throw PayeeException(rejection);
    }
    final payee = await super.addPayee(request);
    if (losePayeeResponse) {
      losePayeeResponse = false;
      throw TimeoutException('The response was lost');
    }
    return payee;
  }

  @override
  Future<List<Payee>> fetchPayees() {
    if (hangPayeeReads) return Completer<List<Payee>>().future;
    if (failPayeeReads) return Future.error(StateError('payees offline'));
    return super.fetchPayees();
  }

  @override
  Future<BankCard> setCardFrozen(String cardId, {required bool frozen}) async {
    if (hangCard) return Completer<BankCard>().future;
    if (refuseCard) throw StateError('refused');
    final card = await super.setCardFrozen(cardId, frozen: frozen);
    if (loseCardResponse) throw TimeoutException('The response was lost');
    return card;
  }

  @override
  Future<List<BankCard>> fetchCards() {
    if (failCardReads) return Future.error(StateError('cards offline'));
    return super.fetchCards();
  }
}

const _name = 'Grace Hopper';
const _bank = 'Navy Federal';
const _account = '998877665';

Future<AddPayeeOutcome> addGrace(WalletController wallet) =>
    wallet.addPayee(name: _name, bankName: _bank, accountNumber: _account);

Iterable<Payee> graces(Iterable<Payee> payees) =>
    payees.where((payee) => payee.accountNumber == _account);

Future<(WalletController, FaultyWalletRepository)> loaded() async {
  final repository = FaultyWalletRepository();
  final wallet = WalletController(repository);
  addTearDown(wallet.dispose);
  await wallet.load();
  return (wallet, repository);
}

/// Loads inside a widget test, where the fake's zero delays need real time.
Future<(WalletController, FaultyWalletRepository)> loadedIn(
  WidgetTester tester,
) async {
  final repository = FaultyWalletRepository();
  final wallet = WalletController(repository);
  await tester.runAsync(wallet.load);
  return (wallet, repository);
}

/// Runs out [duration] in test time, then real time for the fake's delays.
Future<void> elapse(WidgetTester tester, Duration duration) async {
  await tester.pump(duration);
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
}

void main() {
  group('addPayee', () {
    test('saves and reports fresh data', () async {
      final (wallet, _) = await loaded();

      final outcome = await addGrace(wallet);

      expect(outcome, isA<PayeeSaved>());
      expect((outcome as PayeeSaved).isDataFresh, isTrue);
      expect(graces(wallet.payees), hasLength(1));
    });

    test('a lost response is a save once the list shows the payee', () async {
      final (wallet, repository) = await loaded();
      repository.losePayeeResponse = true;

      final outcome = await addGrace(wallet);

      expect(outcome, isA<PayeeSaved>());
      expect((outcome as PayeeSaved).payee.accountNumber, _account);
      expect(graces(wallet.payees), hasLength(1));
    });

    test(
      'a lost response with no list is unknown, and retry saves once',
      () async {
        final (wallet, repository) = await loaded();
        repository
          ..losePayeeResponse = true
          ..failPayeeReads = true;

        expect(await addGrace(wallet), isA<PayeeUnknown>());
        expect(wallet.isDataStale, isTrue);

        repository.failPayeeReads = false;
        final retry = await addGrace(wallet);

        expect(retry, isA<PayeeSaved>());
        expect(repository.payeeKeys.toSet(), hasLength(1));
        expect(graces(await repository.fetchPayees()), hasLength(1));
        expect(graces(wallet.payees), hasLength(1));
      },
    );

    test('a send that never arrived is unknown, and retry saves it', () async {
      final (wallet, repository) = await loaded();
      repository.dropPayee = true;

      expect(await addGrace(wallet), isA<PayeeUnknown>());
      expect(await addGrace(wallet), isA<PayeeSaved>());

      expect(repository.payeeKeys.toSet(), hasLength(1));
      expect(graces(await repository.fetchPayees()), hasLength(1));
    });

    test('different details after an unknown outcome get a new key', () async {
      final (wallet, repository) = await loaded();
      repository.dropPayee = true;
      await addGrace(wallet);

      await wallet.addPayee(
        name: 'Ada Lovelace',
        bankName: _bank,
        accountNumber: '111222333',
      );

      expect(repository.payeeKeys.toSet(), hasLength(2));
    });

    test('a refusal saves nothing and the next try is new', () async {
      final (wallet, repository) = await loaded();
      repository.rejectPayeeWith = 'That account is closed.';

      final outcome = await addGrace(wallet);

      expect(outcome, isA<PayeeRejected>());
      expect((outcome as PayeeRejected).message, 'That account is closed.');
      expect(graces(wallet.payees), isEmpty);
      await addGrace(wallet);
      expect(repository.payeeKeys.toSet(), hasLength(2));
    });

    test('a failed refetch after a save still reports the save', () async {
      final (wallet, repository) = await loaded();
      repository.failPayeeReads = true;

      final outcome = await addGrace(wallet);

      expect(outcome, isA<PayeeSaved>());
      expect((outcome as PayeeSaved).isDataFresh, isFalse);
      expect(wallet.isDataStale, isTrue);
      expect(graces(wallet.payees), hasLength(1));
    });

    testWidgets('a save that never answers ends as unknown', (tester) async {
      final (wallet, repository) = await loadedIn(tester);
      repository.hangPayee = true;

      final outcome = addGrace(wallet);
      await elapse(tester, WalletController.payeeTimeout);
      await elapse(tester, const Duration(seconds: 1));

      expect(await outcome, isA<PayeeUnknown>());
      wallet.dispose();
    });

    testWidgets('a refetch that never answers can\'t hold up a save', (
      tester,
    ) async {
      final (wallet, repository) = await loadedIn(tester);
      repository.hangPayeeReads = true;

      final outcome = addGrace(wallet);
      await elapse(tester, Duration.zero);
      await elapse(tester, WalletController.refreshTimeout);

      expect(await outcome, isA<PayeeSaved>());
      expect(graces(wallet.payees), hasLength(1));
      wallet.dispose();
    });

    test('InMemoryWalletRepository replays a key', () async {
      final repository = InMemoryWalletRepository(latency: Duration.zero);
      const request = AddPayeeRequest(
        idempotencyKey: 'key',
        name: _name,
        bankName: _bank,
        accountNumber: _account,
      );

      final first = await repository.addPayee(request);
      final replay = await repository.addPayee(request);

      expect(replay, same(first));
      expect(graces(await repository.fetchPayees()), hasLength(1));
    });
  });

  group('add recipient screen', () {
    Future<GlobalKey<NavigatorState>> mount(
      WidgetTester tester,
      WalletController wallet,
      List<Object?> results,
    ) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        WalletScope(
          controller: wallet,
          child: MaterialApp(
            navigatorKey: navigator,
            home: const Scaffold(body: Text('Recipients')),
          ),
        ),
      );
      unawaited(
        navigator.currentState!
            .push<Payee>(
              MaterialPageRoute(builder: (_) => const AddRecipientScreen()),
            )
            .then(results.add),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      return navigator;
    }

    Future<void> fill(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        _name,
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Bank'), _bank);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account number'),
        _account,
      );
      await tester.pump();
    }

    Future<void> tapAndWait(WidgetTester tester, String label) async {
      await tester.tap(find.widgetWithText(FilledButton, label));
      for (var i = 0; i < 4; i++) {
        await elapse(tester, const Duration(milliseconds: 150));
      }
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('a lost response carries on with the saved payee', (
      tester,
    ) async {
      final (wallet, repository) = await loadedIn(tester);
      final results = <Object?>[];
      await mount(tester, wallet, results);
      await fill(tester);

      repository.losePayeeResponse = true;
      await tapAndWait(tester, 'Save and continue');

      expect(results.single, isA<Payee>());
      expect(find.text('Recipients'), findsOneWidget);
      wallet.dispose();
    });

    testWidgets('an unknown outcome locks the form and offers a retry', (
      tester,
    ) async {
      final (wallet, repository) = await loadedIn(tester);
      final results = <Object?>[];
      await mount(tester, wallet, results);
      await fill(tester);

      repository
        ..losePayeeResponse = true
        ..failPayeeReads = true;
      await tapAndWait(tester, 'Save and continue');

      expect(results, isEmpty);
      expect(find.textContaining('may be saved already'), findsOneWidget);
      final name = tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Full name'),
          matching: find.byType(EditableText),
        ),
      );
      expect(name.readOnly, isTrue);

      repository.failPayeeReads = false;
      await tapAndWait(tester, 'Retry');

      expect(results.single, isA<Payee>());
      expect(graces(wallet.payees), hasLength(1));
      wallet.dispose();
    });

    testWidgets('a retry isn\'t blocked once the list shows the payee', (
      tester,
    ) async {
      final (wallet, repository) = await loadedIn(tester);
      final results = <Object?>[];
      await mount(tester, wallet, results);
      await fill(tester);
      repository
        ..losePayeeResponse = true
        ..failPayeeReads = true;
      await tapAndWait(tester, 'Save and continue');

      repository.failPayeeReads = false;
      await tester.runAsync(wallet.refresh);
      await tapAndWait(tester, 'Retry');

      expect(results.single, isA<Payee>());
      wallet.dispose();
    });

    testWidgets('a refusal shows its message and stays editable', (
      tester,
    ) async {
      final (wallet, repository) = await loadedIn(tester);
      final results = <Object?>[];
      await mount(tester, wallet, results);
      await fill(tester);

      repository.rejectPayeeWith = 'That account is closed.';
      await tapAndWait(tester, 'Save and continue');

      expect(results, isEmpty);
      expect(find.text('That account is closed.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save and continue'), findsOne);
      wallet.dispose();
    });
  });

  group('setCardFrozen', () {
    testWidgets('a call that never answers ends and rolls back', (
      tester,
    ) async {
      final (wallet, repository) = await loadedIn(tester);
      final card = wallet.cards.firstWhere((card) => !card.isFrozen);
      repository.hangCard = true;

      final failure = expectLater(
        wallet.setCardFrozen(card.id, frozen: true),
        throwsA(isA<TimeoutException>()),
      );
      expect(wallet.isCardUpdating(card.id), isTrue);
      expect(wallet.cardById(card.id)!.isFrozen, isTrue);

      await elapse(tester, WalletController.cardTimeout);
      await elapse(tester, const Duration(seconds: 1));
      await failure;

      expect(wallet.isCardUpdating(card.id), isFalse);
      expect(wallet.cardById(card.id)!.isFrozen, isFalse);
      wallet.dispose();
    });

    test('a lost response keeps a freeze the bank applied', () async {
      final (wallet, repository) = await loaded();
      final card = wallet.cards.firstWhere((card) => !card.isFrozen);
      repository.loseCardResponse = true;

      await wallet.setCardFrozen(card.id, frozen: true);

      expect(wallet.cardById(card.id)!.isFrozen, isTrue);
      expect(wallet.isCardUpdating(card.id), isFalse);
    });

    test('a refusal rolls back to what the bank reports', () async {
      final (wallet, repository) = await loaded();
      final card = wallet.cards.firstWhere((card) => !card.isFrozen);
      repository.refuseCard = true;

      await expectLater(
        wallet.setCardFrozen(card.id, frozen: true),
        throwsStateError,
      );

      expect(wallet.cardById(card.id)!.isFrozen, isFalse);
      expect(wallet.isDataStale, isFalse);
    });

    test('with no way to check, it rolls back and flags stale data', () async {
      final (wallet, repository) = await loaded();
      final card = wallet.cards.firstWhere((card) => !card.isFrozen);
      repository
        ..loseCardResponse = true
        ..failCardReads = true;

      await expectLater(
        wallet.setCardFrozen(card.id, frozen: true),
        throwsA(isA<TimeoutException>()),
      );

      expect(wallet.cardById(card.id)!.isFrozen, isFalse);
      expect(wallet.isDataStale, isTrue);
    });
  });
}
