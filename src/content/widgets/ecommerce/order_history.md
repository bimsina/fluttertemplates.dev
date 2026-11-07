---
title: Order History
description: Past orders with status chips, expandable item details
app: core
path: /ecommerce/order_history
code_files: ["ecommerce/order_history.dart"]
---

## How it works

`ListView.builder` turns `_orders` into `ExpansionTile`s with a status `Chip` in the title row, tinted by `_statusColor`. Leaving `trailing` unset keeps the default arrow, which signals that rows can open. Every order expands to the same hardcoded items and `$61.97` total.

## Adapting it

- Add an `items` list to each `_orders` entry and build the `children` from it.
- `_statusColor` falls through to orange for any unknown status, so add a case for values like cancelled.
- Use `ExpansionTile.onExpansionChanged` in a stateful widget if line items should load on first expand.
