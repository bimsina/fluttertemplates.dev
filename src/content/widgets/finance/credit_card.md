---
title: Credit Card
description: A showcase of Flutter's credit card display functionality
app: core
path: /finance/credit_card
code_files: ["finance/credit_card.dart"]
---

## How it works

Purely presentational: one `Card` holding a purple `LinearGradient`, sized by `AspectRatio` at `1.586`, the proportions of a physical bank card. `MainAxisAlignment.spaceBetween` spreads three rows across it, namely brand, masked number, and holder with expiry. There is no state, no gesture and no flip side for a CVV, and every value, including `VISA`, is hardcoded.

## Adapting it

- Add constructor fields to `CreditCard` for last four digits, holder, expiry and brand.
- Keep the `**** **** **** 4242` masked format and pass only the last four digits in, never a full card number.
- Make the `colors` list a parameter so each brand or account can have its own gradient.
