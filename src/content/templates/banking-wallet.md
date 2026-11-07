---
heroImage: "../../assets/template_images/banking-wallet.png"
title: "Banking Wallet App"
description: "Flutter banking app template with PIN lock screen, account balances, transaction search and filters, send money flow with amount keypad, card freeze toggle, and a CustomPaint spending chart. Flutter SDK only, ChangeNotifier state, integer-cent money, light and dark themes."
summary: "PIN lock, accounts, transactions, transfers, cards and spending insights."
type: full-app
path: /templates/banking_wallet
code_dir: templates/banking_wallet
tags: ["banking", "fintech", "wallet", "finance", "send money", "pin lock", "custompaint", "changenotifier", "full app"]
---

A personal banking app you can run and copy. Everything in the demo works: a transfer changes the balances on every screen, frozen cards stay frozen, and new spending shows up in the insights chart. The data is fake and lives in memory, behind a repository class you can replace.

The demo PIN is 2580. It is shown on the lock screen.

## What's included

- **PIN lock.** Custom keypad with hardware keyboard support, a shake on a wrong PIN, and a 15 second cooldown after five wrong tries. If the PIN can't be checked, the screen says so and offers Try again, and that doesn't count as a wrong try. Locking from the home screen closes everything that was open.
- **Accounts overview.** Each account is a slip sticking out of a wallet, with the total balance, money in and out this month, and recent payees on the front. Balances can be hidden on the main screens; the send flow keeps showing them so you can see what you are sending.
- **Account detail.** Balance and history for a single account, with an empty state for accounts that have no activity.
- **Transactions.** Search by name, category, note or amount. Filter by direction, pending status, period, account and category. Results are grouped by day.
- **Transaction detail.** A receipt view with status, account, card, note and reference, plus Send again for outgoing payments.
- **Send money.** Pick a recipient or one of your own accounts, or add a new recipient through a validated form. Enter the amount on a keypad, review it, and slide to confirm, or focus the slider and press Enter or Space. The amount is checked against the balance and the transfer limit on screen, and again in the repository. If the bank commits the transfer but the refresh after it fails, the success screen still appears, with a notice that balances may be out of date and a Refresh button. If a new recipient gets no answer from the bank, the form locks and offers a retry that can only save them once.
- **Cards.** A swipeable card carousel with a freeze toggle, card number reveal, monthly limit usage, and recent purchases per card. If a freeze fails or goes unanswered, that card is checked against the bank and takes whatever the bank reports.
- **Spending insights.** Six months of spending as a bar chart drawn with CustomPaint, and a ranked category breakdown for the selected month. Tapping a category opens its transactions.

The layout works from 320px wide. At 720px the bottom bar becomes a navigation rail, and at wider sizes the home, activity, cards and insights screens use two columns. Activity opens transactions in a side pane.

## Structure

```text
banking_wallet/
  app.dart      BankingWalletApp: theme, state and the nested Navigator
  models/       Plain Dart classes, money and date formatting, keypad input
  data/         WalletRepository, the swap point, the in-memory version, seed data
  state/        WalletController, WalletScope, spending calculations
  screens/      One file per screen, with the transfer flow in send/
  widgets/      Keypad, wallet stack, card, charts, theme
```

All imports are relative, so you can copy the folder into any project. It needs only the Flutter SDK.

```dart
MaterialApp(home: const BankingWalletApp());
```

`BankingWalletApp` has no `MaterialApp` of its own. It builds its own Navigator and follows the brightness of the theme around it. Every color comes from a `ColorScheme` generated from one seed, so `BankingWalletApp(seedColor: yourBrandColor)` recolors the whole app. To rename the bank, change `brandName` in `widgets/wallet_theme.dart`.

State is one `WalletController`, a `ChangeNotifier` that screens read through `WalletScope`, an `InheritedNotifier`. Use `WalletScope.of(context)` in `build` and `WalletScope.read(context)` in callbacks.

Money is an `int` number of cents everywhere, including keypad input. Amounts are converted to strings only for display.

## Connecting a real backend

Screens never touch the data source. They call `WalletController`, which calls `WalletRepository`, so a backend only has to implement that one class. `data/default_repository.dart` is the only file that names the in-memory version.

1. Implement `WalletRepository` in `data/` with your API client:

   ```dart
   class ApiWalletRepository extends WalletRepository {
     ApiWalletRepository(this._client);

     final BankApiClient _client;

     @override
     Future<List<Account>> fetchAccounts() async {
       final json = await _client.get('/accounts');
       return [for (final item in json) accountFromJson(item)];
     }

     // verifyPin, fetchTransactions, sendMoney and the rest.
   }
   ```

2. Return it from `data/default_repository.dart`, in place of the in-memory one:

   ```dart
   import 'api_wallet_repository.dart';
   import 'wallet_repository.dart';

   WalletRepository createDefaultRepository() =>
       ApiWalletRepository(BankApiClient());
   ```

3. Delete `data/in_memory_wallet_repository.dart` and `data/seed_data.dart`.

`BankingWalletApp(repository: ...)` overrides the default for one app instance, which is useful in tests. It doesn't replace step 2.

A few things to keep in mind:

- `sendMoney` should throw `TransferException`, with a message the customer can read, only when you know no money moved. The review screen shows it and the next try is a new transfer with a new key.
- Any other error, or no answer within 30 seconds, counts as an unknown outcome. The review screen says the transfer may have gone through, locks the note, and offers a retry of the same request.
- `TransferRequest.idempotencyKey` is generated on the device for each attempt and stays the same across retries of it. Send it to your API and make the server honor it: a key that already succeeded must return the original debit without moving money, as `InMemoryWalletRepository` does. The retry is only safe if the server does this.
- `WalletController` remembers transfers with an unknown outcome so that leaving the review screen and coming back keeps the key, but only in memory. If a restart must not lose them, persist them.
- If the refresh after a transfer fails, `WalletController` applies the returned debit locally and sets `isDataStale` until a refresh works. Those balances are an estimate, not what the bank reported.
- `addPayee` takes an `AddPayeeRequest`. Throw `PayeeException`, with a message the customer can read, only when you know nothing was saved. Any other error, or no answer within 30 seconds, counts as an unknown outcome: `WalletController` refetches the payees, and if the account number is there the save counts as done. Otherwise the form offers a retry with the same `idempotencyKey`, so make the server honor it the way `sendMoney` does. Unknown attempts are matched on their exact details and kept in memory only, so someone who leaves the form and types different details gets a new key.
- `setCardFrozen` is sent again after a failure, so setting the state a card already has must succeed. An error, or no answer within 15 seconds, makes `WalletController` read the card back. If the bank shows the requested state the call counts as done. Otherwise the card takes the bank's state. If that read fails too, the card goes back to its old state, `isDataStale` is set, and the change may still land on the server.
- Leave `pinHint` as `null` and the demo PIN disappears from the lock screen.
- `verifyPin` returns whether the PIN is right. Throw when it couldn't be checked: an error, or no answer within 15 seconds, gives `PinResult.unavailable`, which keeps the keypad usable and counts no attempt.
- Verify the PIN on the server and enforce the lockout there. The cooldown in `WalletController` is only a UI courtesy, and it resets when the app restarts.
- `fetchTransactions` returns the full history. For real accounts, add paging to the repository and to `TransactionBrowser`.
- `BankCard` carries the full number and CVV to demonstrate the reveal. In production, fetch them through a separate short-lived call when the customer asks, and keep them out of the card list.
- The PIN screen only gates the UI. Keep session tokens in secure storage, and lock the app when it goes to the background if your security policy needs that.
