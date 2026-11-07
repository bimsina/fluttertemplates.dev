---
title: Wallet Overview
description: A showcase of Flutter's wallet overview functionality
app: core
path: /finance/wallet_overview
code_files: ["finance/wallet_overview.dart"]
---

## How it works

A total card sits above one `ListTile` per entry in `_wallets`, with the leading icon tinted by each wallet's `color`. The `$22,870.50` total is a literal that happens to match the three balances today but will not follow them if they change. The `chevron_right` hints at navigation, yet no tile has an `onTap`.

## Adapting it

- Store `balance` as a number and sum `_wallets` for the total.
- Add `onTap` to each `ListTile` and open that wallet's transactions.
- Format amounts at render time with `NumberFormat.currency` from `intl`, which also handles multiple currencies better than literal `balance` strings.
