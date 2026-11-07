---
title: Bill Payment
description: A showcase of Flutter's bill payment functionality
app: core
path: /finance/bill_payment
code_files: ["finance/bill_payment.dart"]
---

## How it works

`_bills` drives a list of `Card`s in which the `paid` flag shows either a green check or a tonal Pay button, and each `Wrap` moves the controls down a line when text is large. `totalDue` sums the unpaid bills in `build`, which starts at $267. Pay and Pay All add names to `_paid` in memory, confirm with a demo `SnackBar`, and call `onPay` once per bill.

## Adapting it

- Update `_paid` only after your payment API succeeds, instead of optimistically.
- Show a confirmation dialog before `Pay All` runs, since it moves money for several bills at once.
- Whole-dollar `amount` values can't hold cents, so store minor units for real bills.
