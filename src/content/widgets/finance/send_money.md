---
title: Send Money
description: A showcase of Flutter's send money functionality
app: core
path: /finance/send_money
code_files: ["finance/send_money.dart"]
---

## How it works

An amount field, a row of `CircleAvatar` contacts and a Recent list feed one send button. The amount accepts two decimals, and tapping a contact or Recent row sets `_recipient`. `_send` shows an inline error until both are valid, then calls `onSend`, or a demo `SnackBar` without it. Recent rows reuse the first three `_contacts` with a hardcoded `•••• 4242`.

## Adapting it

- Call your transfer API from `onSend`, and use integer minor units rather than `double` there.
- `Row` with `spaceBetween` will overflow as contacts grow, so move to a horizontal `ListView`.
