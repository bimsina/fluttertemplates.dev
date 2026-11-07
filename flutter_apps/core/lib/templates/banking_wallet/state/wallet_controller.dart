import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/wallet_repository.dart';
import '../models/account.dart';
import '../models/bank_card.dart';
import '../models/customer.dart';
import '../models/payee.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';

enum WalletLoadStatus { loading, ready, failed }

/// [unavailable] means the bank gave no verdict, for example because the network
/// failed. It says nothing about the PIN, so it never counts as an attempt.
enum PinResult { correct, wrong, lockedOut, unavailable }

/// The app's single source of truth. Screens read it through `WalletScope`
/// and rebuild when it notifies; it calls the repository for everything else.
class WalletController extends ChangeNotifier {
  WalletController(this._repository);

  static const int maxPinAttempts = 5;
  static const Duration pinCooldown = Duration(seconds: 15);

  /// How long a PIN check may go unanswered before it counts as unavailable.
  static const Duration pinCheckTimeout = Duration(seconds: 15);

  /// How long a transfer may go unanswered before its outcome counts as
  /// unknown.
  static const Duration transferTimeout = Duration(seconds: 30);

  /// How long saving a payee may go unanswered before its outcome counts as
  /// unknown.
  static const Duration payeeTimeout = Duration(seconds: 30);

  /// How long a card freeze may go unanswered before the card is checked.
  static const Duration cardTimeout = Duration(seconds: 15);

  /// How long a refresh may hold up the screen after a transfer.
  static const Duration refreshTimeout = Duration(seconds: 10);

  final WalletRepository _repository;
  bool _disposed = false;

  WalletLoadStatus _status = WalletLoadStatus.loading;
  Customer? _customer;
  List<Account> _accounts = const [];
  List<Transaction> _transactions = const [];
  List<BankCard> _cards = const [];
  List<Payee> _payees = const [];
  final Set<String> _cardsUpdating = {};
  final Map<String, TransferRequest> _unresolvedTransfers = {};
  final Map<String, AddPayeeRequest> _unresolvedPayees = {};
  bool _isDataStale = false;

  bool _isUnlocked = false;
  int _failedPinAttempts = 0;
  DateTime? _pinLockedUntil;
  bool _balancesHidden = false;

  WalletLoadStatus get status => _status;
  Customer? get customer => _customer;
  List<Account> get accounts => _accounts;
  List<Transaction> get transactions => _transactions;
  List<BankCard> get cards => _cards;
  List<Payee> get payees => _payees;

  /// True after a refresh failed, until one succeeds. Balances and activity
  /// may not match the bank in the meantime.
  bool get isDataStale => _isDataStale;

  bool get isUnlocked => _isUnlocked;
  bool get balancesHidden => _balancesHidden;
  String? get pinHint => _repository.pinHint;
  int get pinLength => _repository.pinLength;
  int get failedPinAttempts => _failedPinAttempts;
  DateTime? get pinLockedUntil => _pinLockedUntil;

  int get totalBalanceCents =>
      _accounts.fold(0, (sum, account) => sum + account.balanceCents);

  /// The customer's own accounts, as destinations for a transfer.
  List<Payee> get ownAccountPayees => [
    for (final account in _accounts)
      Payee(
        id: 'own_${account.id}',
        name: account.name,
        bankName: account.kind.label,
        accountNumber: account.lastFour,
        ownAccountId: account.id,
      ),
  ];

  Account? accountById(String? id) =>
      _firstWhereOrNull(_accounts, id, (a) => a.id);

  BankCard? cardById(String? id) => _firstWhereOrNull(_cards, id, (c) => c.id);

  Payee? payeeById(String? id) => _firstWhereOrNull(_payees, id, (p) => p.id);

  Transaction? transactionById(String? id) =>
      _firstWhereOrNull(_transactions, id, (t) => t.id);

  bool isCardUpdating(String cardId) => _cardsUpdating.contains(cardId);

  /// A transfer with these details whose outcome is unknown. The review screen
  /// resends it, key included, so leaving and coming back can't pay twice.
  TransferRequest? unresolvedTransfer({
    required String fromAccountId,
    required String payeeId,
    required int amountCents,
  }) {
    for (final request in _unresolvedTransfers.values) {
      if (request.fromAccountId == fromAccountId &&
          request.payee.id == payeeId &&
          request.amountCents == amountCents) {
        return request;
      }
    }
    return null;
  }

  /// Saved payees, most recently paid first.
  List<Payee> get recentPayees {
    final ids = <String>{};
    for (final transaction in _transactions) {
      final id = transaction.payeeId;
      if (id != null && transaction.amountCents < 0) ids.add(id);
    }
    final recent = [for (final id in ids) ?payeeById(id)];
    return [...recent, ..._payees.where((payee) => !ids.contains(payee.id))];
  }

  Future<void> load() async {
    _status = WalletLoadStatus.loading;
    notifyListeners();
    try {
      await _refresh();
      _status = WalletLoadStatus.ready;
    } catch (error, stackTrace) {
      debugPrint('Wallet failed to load: $error\n$stackTrace');
      _status = WalletLoadStatus.failed;
    }
    notifyListeners();
  }

  Future<void> _refresh() async {
    final (customer, accounts, transactions, cards, payees) = await (
      _repository.fetchCustomer(),
      _repository.fetchAccounts(),
      _repository.fetchTransactions(),
      _repository.fetchCards(),
      _repository.fetchPayees(),
    ).wait;
    _customer = customer;
    _accounts = accounts;
    _transactions = transactions;
    _cards = cards;
    _payees = payees;
    _isDataStale = false;
  }

  /// Reloads everything in place and returns whether that worked. Unlike
  /// [load], a failure keeps the current data on screen and marks it stale.
  Future<bool> refresh() async {
    final refreshed = await _tryRefresh();
    notifyListeners();
    return refreshed;
  }

  Future<bool> _tryRefresh() async {
    try {
      await _refresh().timeout(refreshTimeout);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Wallet failed to refresh: $error\n$stackTrace');
      _isDataStale = true;
      return false;
    }
  }

  /// Checks the PIN. Never throws: a check that fails or goes unanswered
  /// returns [PinResult.unavailable] and leaves the attempt count alone.
  Future<PinResult> submitPin(String pin) async {
    final lockedUntil = _pinLockedUntil;
    if (lockedUntil != null && DateTime.now().isBefore(lockedUntil)) {
      return PinResult.lockedOut;
    }
    final bool isCorrect;
    try {
      isCorrect = await _repository.verifyPin(pin).timeout(pinCheckTimeout);
    } catch (error, stackTrace) {
      debugPrint('PIN check failed: $error\n$stackTrace');
      return PinResult.unavailable;
    }
    if (isCorrect) {
      _failedPinAttempts = 0;
      _pinLockedUntil = null;
      _isUnlocked = true;
      notifyListeners();
      return PinResult.correct;
    }
    _failedPinAttempts++;
    final lockedOut = _failedPinAttempts >= maxPinAttempts;
    if (lockedOut) {
      _failedPinAttempts = 0;
      _pinLockedUntil = DateTime.now().add(pinCooldown);
    }
    notifyListeners();
    return lockedOut ? PinResult.lockedOut : PinResult.wrong;
  }

  void lock() {
    _isUnlocked = false;
    notifyListeners();
  }

  void toggleBalancesHidden() {
    _balancesHidden = !_balancesHidden;
    notifyListeners();
  }

  /// Sends the money, then refreshes so every screen shows the new balances.
  ///
  /// The two steps report separately: once the bank commits, the result is
  /// [TransferCommitted] whatever the refresh does. Never throws.
  Future<TransferOutcome> sendMoney(TransferRequest request) async {
    final Transaction transaction;
    try {
      transaction = await _repository
          .sendMoney(request)
          .timeout(transferTimeout);
    } on TransferException catch (error) {
      _unresolvedTransfers.remove(request.idempotencyKey);
      notifyListeners();
      return TransferRejected(error.message);
    } catch (error, stackTrace) {
      debugPrint('Transfer outcome unknown: $error\n$stackTrace');
      _unresolvedTransfers[request.idempotencyKey] = request;
      // If the money did move, this lets Activity show it.
      await _tryRefresh();
      notifyListeners();
      return const TransferUnknown();
    }

    _unresolvedTransfers.remove(request.idempotencyKey);
    final refreshed = await _tryRefresh();
    if (!refreshed) _applyCommittedTransfer(request, transaction);
    notifyListeners();
    return TransferCommitted(transaction, isDataFresh: refreshed);
  }

  /// Local estimate of a commit the refresh couldn't fetch, so the success
  /// screen and receipt have a transaction to show. A transaction already in
  /// the list came from the bank and its balances include it.
  void _applyCommittedTransfer(TransferRequest request, Transaction debit) {
    if (transactionById(debit.id) != null) return;
    final destinationId = request.payee.ownAccountId;
    _transactions = [debit, ..._transactions];
    _accounts = [
      for (final account in _accounts)
        if (account.id == debit.accountId)
          account.copyWith(
            balanceCents: account.balanceCents + debit.amountCents,
          )
        else if (account.id == destinationId)
          account.copyWith(
            balanceCents: account.balanceCents + request.amountCents,
          )
        else
          account,
    ];
  }

  /// Saves a payee, then refetches the list.
  ///
  /// The two steps report separately: once the bank has the payee, the result
  /// is [PayeeSaved] whatever the refetch does. Adding the same details after
  /// [PayeeUnknown] reuses that attempt's key, so it can't save a second
  /// payee. Never throws.
  Future<AddPayeeOutcome> addPayee({
    required String name,
    required String bankName,
    required String accountNumber,
  }) async {
    final request =
        _unresolvedPayee(name, bankName, accountNumber) ??
        AddPayeeRequest(
          idempotencyKey: generateIdempotencyKey(),
          name: name,
          bankName: bankName,
          accountNumber: accountNumber,
        );
    final Payee payee;
    try {
      payee = await _repository.addPayee(request).timeout(payeeTimeout);
    } on PayeeException catch (error) {
      _unresolvedPayees.remove(request.idempotencyKey);
      notifyListeners();
      return PayeeRejected(error.message);
    } catch (error, stackTrace) {
      debugPrint('Payee outcome unknown: $error\n$stackTrace');
      _unresolvedPayees[request.idempotencyKey] = request;
      // A lost response isn't a lost payee: the list can show it arrived.
      final refreshed = await _tryRefreshPayees();
      final saved = _payees
          .where((known) => known.accountNumber == accountNumber)
          .firstOrNull;
      if (saved != null) _unresolvedPayees.remove(request.idempotencyKey);
      notifyListeners();
      return saved == null
          ? const PayeeUnknown()
          : PayeeSaved(saved, isDataFresh: refreshed);
    }

    _unresolvedPayees.remove(request.idempotencyKey);
    final refreshed = await _tryRefreshPayees();
    if (payeeById(payee.id) == null) _payees = [..._payees, payee];
    notifyListeners();
    return PayeeSaved(payee, isDataFresh: refreshed);
  }

  AddPayeeRequest? _unresolvedPayee(
    String name,
    String bankName,
    String accountNumber,
  ) {
    for (final request in _unresolvedPayees.values) {
      if (request.name == name &&
          request.bankName == bankName &&
          request.accountNumber == accountNumber) {
        return request;
      }
    }
    return null;
  }

  Future<bool> _tryRefreshPayees() async {
    try {
      _payees = await _repository.fetchPayees().timeout(refreshTimeout);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Payees failed to refresh: $error\n$stackTrace');
      _isDataStale = true;
      return false;
    }
  }

  /// Flips the card right away. If the call fails or goes unanswered, the card
  /// is checked against the bank, because the change may have landed anyway.
  ///
  /// Completes normally when the bank shows the state that was asked for.
  /// Otherwise that card takes the bank's state, or its old one if the check
  /// fails too, and this rethrows so the screen can say what happened. Other
  /// cards keep whatever changed while this call was running.
  Future<void> setCardFrozen(String cardId, {required bool frozen}) async {
    if (_cardsUpdating.contains(cardId)) return;
    final wasFrozen = cardById(cardId)?.isFrozen ?? !frozen;
    _replaceFrozen(cardId, frozen);
    _cardsUpdating.add(cardId);
    notifyListeners();
    try {
      await _repository
          .setCardFrozen(cardId, frozen: frozen)
          .timeout(cardTimeout);
    } catch (error, stackTrace) {
      debugPrint('Card update failed: $error\n$stackTrace');
      final actual = await _fetchFrozen(cardId);
      if (actual == frozen) return;
      _replaceFrozen(cardId, actual ?? wasFrozen);
      rethrow;
    } finally {
      _cardsUpdating.remove(cardId);
      notifyListeners();
    }
  }

  /// What the bank says about one card, or null if it can't be reached.
  Future<bool?> _fetchFrozen(String cardId) async {
    try {
      final cards = await _repository.fetchCards().timeout(refreshTimeout);
      return cards.where((card) => card.id == cardId).firstOrNull?.isFrozen;
    } catch (error, stackTrace) {
      debugPrint('Card check failed: $error\n$stackTrace');
      _isDataStale = true;
      return null;
    }
  }

  void _replaceFrozen(String cardId, bool frozen) {
    _cards = [
      for (final card in _cards)
        card.id == cardId ? card.copyWith(isFrozen: frozen) : card,
    ];
  }

  @override
  void notifyListeners() {
    // Repository calls can finish after the app has been removed.
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

T? _firstWhereOrNull<T>(
  List<T> items,
  String? id,
  String Function(T item) idOf,
) {
  if (id == null) return null;
  for (final item in items) {
    if (idOf(item) == id) return item;
  }
  return null;
}
