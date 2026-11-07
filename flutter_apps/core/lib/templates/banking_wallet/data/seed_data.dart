import 'dart:math';

import '../models/account.dart';
import '../models/bank_card.dart';
import '../models/customer.dart';
import '../models/payee.dart';
import '../models/transaction.dart';

/// Fake data for [InMemoryWalletRepository]. Delete this file once you connect
/// a real backend.
///
/// Balances are fixed starting points and are not derived from the history
/// below. The history is generated relative to today, so the demo never looks
/// stale, and from a fixed random seed, so it looks the same on every run.
const Customer seedCustomer = Customer(
  firstName: 'Maya',
  fullName: 'Maya Lindqvist',
);

const String checkingId = 'acc_everyday';
const String savingsId = 'acc_rainy_day';
const String potId = 'acc_lisbon';

const String debitCardId = 'card_everyday';
const String virtualCardId = 'card_online';
const String travelCardId = 'card_travel';

const List<Account> seedAccounts = [
  Account(
    id: checkingId,
    name: 'Everyday',
    kind: AccountKind.checking,
    lastFour: '4821',
    balanceCents: 421836,
  ),
  Account(
    id: savingsId,
    name: 'Rainy Day',
    kind: AccountKind.savings,
    lastFour: '7730',
    balanceCents: 1264000,
  ),
  // Has no history, so the account screen shows its empty state.
  Account(
    id: potId,
    name: 'Lisbon Trip',
    kind: AccountKind.pot,
    lastFour: '1195',
    balanceCents: 86050,
  ),
];

const List<BankCard> seedCards = [
  BankCard(
    id: debitCardId,
    accountId: checkingId,
    label: 'Everyday',
    kind: CardKind.debit,
    holder: 'Maya Lindqvist',
    number: '4000123412344821',
    expiry: '09/29',
    cvv: '417',
    monthlyLimitCents: 200000,
  ),
  BankCard(
    id: virtualCardId,
    accountId: checkingId,
    label: 'Online shopping',
    kind: CardKind.virtual,
    holder: 'Maya Lindqvist',
    number: '4000123412349076',
    expiry: '03/28',
    cvv: '982',
    monthlyLimitCents: 50000,
  ),
  BankCard(
    id: travelCardId,
    accountId: potId,
    label: 'Travel',
    kind: CardKind.debit,
    holder: 'Maya Lindqvist',
    number: '4000123412341195',
    expiry: '11/28',
    cvv: '260',
    monthlyLimitCents: 100000,
    isFrozen: true,
  ),
];

const List<Payee> seedPayees = [
  Payee(
    id: 'payee_priya',
    name: 'Priya Nair',
    bankName: 'Harbor Credit Union',
    accountNumber: '20418837',
  ),
  Payee(
    id: 'payee_tom',
    name: 'Tom Okafor',
    bankName: 'First Meridian',
    accountNumber: '77120463',
  ),
  Payee(
    id: 'payee_lena',
    name: 'Lena Fischer',
    bankName: 'Harbor Credit Union',
    accountNumber: '30955214',
  ),
  Payee(
    id: 'payee_sam',
    name: 'Sam Reyes',
    bankName: 'Northwind Bank',
    accountNumber: '51186902',
  ),
  Payee(
    id: 'payee_landlord',
    name: 'Cedar Street Lettings',
    bankName: 'First Meridian',
    accountNumber: '90033127',
  ),
];

class _Merchant {
  const _Merchant(this.name, this.category, this.minCents, this.maxCents);

  final String name;
  final TransactionCategory category;
  final int minCents;
  final int maxCents;
}

const List<_Merchant> _everydayMerchants = [
  _Merchant('Fern & Fig Market', TransactionCategory.groceries, 1840, 8650),
  _Merchant('Corner Pantry', TransactionCategory.groceries, 620, 2480),
  _Merchant('Halo Coffee', TransactionCategory.dining, 425, 1150),
  _Merchant('Noodle Yard', TransactionCategory.dining, 1380, 3640),
  _Merchant('The Olive Room', TransactionCategory.dining, 2850, 7420),
  _Merchant('Northline Transit', TransactionCategory.transport, 275, 1260),
  _Merchant('Zip Rides', TransactionCategory.transport, 890, 2840),
  _Merchant('Wool & Thread', TransactionCategory.shopping, 2400, 11800),
  _Merchant('Paperback Corner', TransactionCategory.shopping, 1299, 3899),
  _Merchant('Lumen Cinema', TransactionCategory.entertainment, 1250, 3100),
  _Merchant('Greenleaf Pharmacy', TransactionCategory.health, 840, 3650),
];

/// Builds about six months of history ending today, newest first.
List<Transaction> buildSeedTransactions(DateTime now) {
  final random = Random(7);
  final transactions = <Transaction>[];
  var sequence = 0;

  void add({
    required int daysAgo,
    required String title,
    required TransactionCategory category,
    required int amountCents,
    String accountId = checkingId,
    String? cardId,
    String? payeeId,
    String? counterAccountId,
    String? note,
    TransactionStatus status = TransactionStatus.completed,
    int minutesAgo = 0,
  }) {
    sequence++;
    final midday = DateTime(now.year, now.month, now.day - daysAgo, 18);
    final date = daysAgo == 0
        ? now.subtract(Duration(minutes: 22 + minutesAgo))
        : midday.subtract(Duration(minutes: minutesAgo));
    transactions.add(
      Transaction(
        id: 'seed_$sequence',
        accountId: accountId,
        title: title,
        category: category,
        amountCents: amountCents,
        date: date,
        reference: 'BF${(48210000 + sequence * 37).toString()}',
        cardId: cardId,
        payeeId: payeeId,
        counterAccountId: counterAccountId,
        note: note,
        status: status,
      ),
    );
  }

  for (var daysAgo = 0; daysAgo < 185; daysAgo++) {
    final day = DateTime(now.year, now.month, now.day - daysAgo);

    switch (day.day) {
      case 1:
        add(
          daysAgo: daysAgo,
          title: 'Cedar Street Lettings',
          category: TransactionCategory.housing,
          amountCents: -145000,
          payeeId: 'payee_landlord',
          note: 'Rent',
        );
      case 3:
        add(
          daysAgo: daysAgo,
          title: 'Volt Energy',
          category: TransactionCategory.bills,
          amountCents: -(7200 + random.nextInt(2600)),
        );
      case 5:
        add(
          daysAgo: daysAgo,
          title: 'Streamly',
          category: TransactionCategory.entertainment,
          amountCents: -1599,
          cardId: virtualCardId,
        );
      case 9:
        add(
          daysAgo: daysAgo,
          title: 'Aerial Mobile',
          category: TransactionCategory.bills,
          amountCents: -3400,
        );
      case 15:
        add(
          daysAgo: daysAgo,
          title: 'Ironworks Gym',
          category: TransactionCategory.health,
          amountCents: -3900,
          cardId: debitCardId,
        );
      case 25:
        add(
          daysAgo: daysAgo,
          title: 'Brightside Studio Payroll',
          category: TransactionCategory.income,
          amountCents: 485000,
          note: 'Salary',
        );
      case 26:
        add(
          daysAgo: daysAgo,
          title: 'To Rainy Day',
          category: TransactionCategory.transfer,
          amountCents: -30000,
          counterAccountId: savingsId,
          note: 'Monthly savings',
        );
        add(
          daysAgo: daysAgo,
          title: 'From Everyday',
          category: TransactionCategory.transfer,
          amountCents: 30000,
          accountId: savingsId,
          counterAccountId: checkingId,
          note: 'Monthly savings',
        );
      case 28:
        add(
          daysAgo: daysAgo,
          title: 'Interest earned',
          category: TransactionCategory.income,
          amountCents: 2100 + random.nextInt(500),
          accountId: savingsId,
        );
    }

    // Every eleventh day, settle up with a friend in one direction or another.
    if (daysAgo % 11 == 4) {
      final friend = seedPayees[random.nextInt(4)];
      final paidBack = random.nextBool();
      final amount = 1500 + random.nextInt(6000);
      add(
        daysAgo: daysAgo,
        title: friend.name,
        category: paidBack
            ? TransactionCategory.income
            : TransactionCategory.transfer,
        amountCents: paidBack ? amount : -amount,
        payeeId: friend.id,
        note: paidBack ? 'Dinner, my share' : 'Concert tickets',
        minutesAgo: 90,
      );
    }

    // Two recent purchases are always in the list, then a random 0 to 2 a day.
    final purchases = daysAgo < 2 ? 2 : random.nextInt(3);
    for (var i = 0; i < purchases; i++) {
      final merchant =
          _everydayMerchants[random.nextInt(_everydayMerchants.length)];
      final online = merchant.category == TransactionCategory.shopping;
      final range = merchant.maxCents - merchant.minCents;
      add(
        daysAgo: daysAgo,
        title: merchant.name,
        category: merchant.category,
        amountCents: -(merchant.minCents + random.nextInt(range)),
        cardId: online ? virtualCardId : debitCardId,
        status: daysAgo == 0
            ? TransactionStatus.pending
            : TransactionStatus.completed,
        minutesAgo: 140 * i + 11,
      );
    }
  }

  transactions.sort((a, b) => b.date.compareTo(a.date));
  return transactions;
}
