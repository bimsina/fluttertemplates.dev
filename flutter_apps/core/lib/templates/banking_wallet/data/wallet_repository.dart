import '../models/account.dart';
import '../models/bank_card.dart';
import '../models/customer.dart';
import '../models/payee.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';

/// Everything the app needs from a bank backend.
///
/// `InMemoryWalletRepository` implements this with fake data. To use a real
/// API, implement this class and return it from `createDefaultRepository()` in
/// `default_repository.dart`.
/// Nothing above this layer knows where the data comes from.
abstract class WalletRepository {
  /// A PIN to display on the lock screen. Demo only: real backends leave this
  /// as `null` and the hint disappears.
  String? get pinHint => null;

  int get pinLength => 4;

  /// Returns whether [pin] is correct. Throw when you couldn't check it, such
  /// as on a network error: the lock screen then offers a retry and doesn't
  /// count a wrong attempt.
  Future<bool> verifyPin(String pin);

  Future<Customer> fetchCustomer();

  Future<List<Account>> fetchAccounts();

  /// All transactions, newest first.
  Future<List<Transaction>> fetchTransactions();

  Future<List<BankCard>> fetchCards();

  Future<List<Payee>> fetchPayees();

  /// Saves the payee and returns it.
  ///
  /// Must be idempotent on [AddPayeeRequest.idempotencyKey]: a key that already
  /// succeeded returns the original payee and saves nothing.
  ///
  /// Throw [PayeeException] only when you know nothing was saved. Any other
  /// error, such as a timeout, is treated as an unknown outcome.
  Future<Payee> addPayee(AddPayeeRequest request);

  /// Moves the money and returns the debit on the source account.
  ///
  /// Must be idempotent on [TransferRequest.idempotencyKey]: a key that already
  /// succeeded returns the original debit and moves nothing.
  ///
  /// Throw [TransferException] only when you know no money moved. The client
  /// validates too, but this is the check that counts. Any other error, such
  /// as a timeout, is treated as an unknown outcome.
  Future<Transaction> sendMoney(TransferRequest request);

  /// Sets the freeze state. Setting the state a card already has must succeed,
  /// because this is resent after an answer that never came.
  Future<BankCard> setCardFrozen(String cardId, {required bool frozen});
}
