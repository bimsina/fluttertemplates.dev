import '../models/account.dart';
import '../models/bank_card.dart';
import '../models/customer.dart';
import '../models/payee.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import 'seed_data.dart';
import 'wallet_repository.dart';

/// A fake bank that lives in memory and resets when the app restarts.
///
/// It behaves like a server: it owns the balances, re-validates transfers, and
/// answers after a short delay, so the loading and busy states in the UI are
/// real and carry over unchanged to a network-backed repository.
class InMemoryWalletRepository extends WalletRepository {
  InMemoryWalletRepository({
    this.latency = const Duration(milliseconds: 350),
    DateTime? now,
  }) : _accounts = List.of(seedAccounts),
       _cards = List.of(seedCards),
       _payees = List.of(seedPayees),
       _transactions = buildSeedTransactions(now ?? DateTime.now());

  static const String _demoPin = '2580';

  final Duration latency;

  final List<Account> _accounts;
  final List<BankCard> _cards;
  final List<Payee> _payees;
  final List<Transaction> _transactions;
  final Map<String, (TransferRequest, Transaction)> _committedTransfers = {};
  final Map<String, Payee> _savedPayees = {};
  int _nextId = 1;

  Future<void> _simulateNetwork() => Future<void>.delayed(latency);

  @override
  String? get pinHint => _demoPin;

  @override
  Future<bool> verifyPin(String pin) async {
    await _simulateNetwork();
    return pin == _demoPin;
  }

  @override
  Future<Customer> fetchCustomer() async {
    await _simulateNetwork();
    return seedCustomer;
  }

  @override
  Future<List<Account>> fetchAccounts() async {
    await _simulateNetwork();
    return List.unmodifiable(_accounts);
  }

  @override
  Future<List<Transaction>> fetchTransactions() async {
    await _simulateNetwork();
    return List.unmodifiable(_transactions);
  }

  @override
  Future<List<BankCard>> fetchCards() async {
    await _simulateNetwork();
    return List.unmodifiable(_cards);
  }

  @override
  Future<List<Payee>> fetchPayees() async {
    await _simulateNetwork();
    return List.unmodifiable(_payees);
  }

  @override
  Future<Payee> addPayee(AddPayeeRequest request) async {
    await _simulateNetwork();
    final saved = _savedPayees[request.idempotencyKey];
    if (saved != null) return saved;
    final payee = Payee(
      id: 'payee_new_${_nextId++}',
      name: request.name,
      bankName: request.bankName,
      accountNumber: request.accountNumber,
    );
    _payees.insert(0, payee);
    _savedPayees[request.idempotencyKey] = payee;
    return payee;
  }

  @override
  Future<Transaction> sendMoney(TransferRequest request) async {
    await _simulateNetwork();

    // Checked before validation: a replay must return the original debit even
    // if the balance can no longer cover it.
    final committed = _committedTransfers[request.idempotencyKey];
    if (committed != null) {
      final (original, debit) = committed;
      if (!original.hasSameDetails(request)) {
        throw const TransferException(
          'This transfer was already sent with different details.',
        );
      }
      return debit;
    }

    final source = _accountIndex(request.fromAccountId);
    if (source < 0) throw const TransferException('Account not found.');
    if (request.amountCents <= 0) {
      throw const TransferException('Enter an amount above zero.');
    }
    if (request.amountCents > transferLimitCents) {
      throw const TransferException('That is over the limit per transfer.');
    }
    if (request.amountCents > _accounts[source].balanceCents) {
      throw const TransferException('Not enough money in this account.');
    }

    final payee = request.payee;
    final destination = payee.isOwnAccount
        ? _accountIndex(payee.ownAccountId!)
        : -1;
    if (payee.isOwnAccount && destination < 0) {
      throw const TransferException('Account not found.');
    }
    if (destination == source) {
      throw const TransferException('Choose a different account to send from.');
    }

    final now = DateTime.now();
    final sourceAccount = _accounts[source];
    final note = request.note;

    _accounts[source] = sourceAccount.copyWith(
      balanceCents: sourceAccount.balanceCents - request.amountCents,
    );
    final debit = Transaction(
      id: 'txn_${_nextId++}',
      accountId: sourceAccount.id,
      title: payee.isOwnAccount ? 'To ${payee.name}' : payee.name,
      category: TransactionCategory.transfer,
      amountCents: -request.amountCents,
      date: now,
      reference: 'BF${now.millisecondsSinceEpoch % 100000000}',
      note: note,
      payeeId: payee.isOwnAccount ? null : payee.id,
      counterAccountId: payee.ownAccountId,
    );
    _transactions.insert(0, debit);

    if (destination >= 0) {
      final target = _accounts[destination];
      _accounts[destination] = target.copyWith(
        balanceCents: target.balanceCents + request.amountCents,
      );
      _transactions.insert(
        0,
        Transaction(
          id: 'txn_${_nextId++}',
          accountId: target.id,
          title: 'From ${sourceAccount.name}',
          category: TransactionCategory.transfer,
          amountCents: request.amountCents,
          date: now,
          reference: debit.reference,
          note: note,
          counterAccountId: sourceAccount.id,
        ),
      );
    }
    _committedTransfers[request.idempotencyKey] = (request, debit);
    return debit;
  }

  @override
  Future<BankCard> setCardFrozen(String cardId, {required bool frozen}) async {
    await _simulateNetwork();
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index < 0) throw StateError('Unknown card $cardId');
    return _cards[index] = _cards[index].copyWith(isFrozen: frozen);
  }

  int _accountIndex(String id) {
    return _accounts.indexWhere((account) => account.id == id);
  }
}
