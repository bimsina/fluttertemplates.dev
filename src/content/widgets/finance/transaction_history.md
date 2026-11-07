---
title: Transaction History
description: A showcase of Flutter's transaction history functionality
app: core
path: /finance/transaction_history
code_files: ["finance/transaction_history.dart"]
---

## How it works

`ListView.separated` puts a `Divider` between six `_transactions`. Each row works out `isCredit` by checking whether the `amount` string begins with `+`, coloring credits green and leaving debits on `onSurface`. Dates like `Today` and `Mar 1` are display strings, so there is no grouping or paging.

## Adapting it

- Model `amount` as a signed number and derive both the sign and `isCredit` from the value.
- Use `DateTime` for `date` and insert day headers, which `separatorBuilder` can do by comparing neighboring rows.
- Attach a `ScrollController` to load older pages from your API instead of the const `_transactions`.
