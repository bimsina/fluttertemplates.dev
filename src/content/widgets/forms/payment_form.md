---
title: Payment Form
description: Card input with formatting and live card preview
app: core
path: /forms/payment/payment_form
code_files: ["forms/payment/payment_form.dart"]
---

## How it works

`_CardNumberFormatter` strips non-digits, caps the number at 16 digits and adds a space every four, keeping the cursor after the same digit. A listener on `_cardController` copies that text into `_cardDisplay` for the preview card and restores `_cardPlaceholder` when the field is empty. Pay runs the `Form` validators: a Luhn check, an unexpired MM/YY from `_ExpiryFormatter`, a 3 or 4 digit CVV and a name. Valid input reaches `onSubmit` as `PaymentDetails`, and without it the demo shows a `SnackBar`.

## Adapting it

- American Express uses 15 digits in different groups, so extend `_CardNumberFormatter` if you accept it.
- Hand `PaymentDetails` to your payment provider's SDK from `onSubmit`; don't post it to your own server.
