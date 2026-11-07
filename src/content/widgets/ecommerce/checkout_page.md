---
title: Checkout Flow
description: Stepper-based checkout - shipping, payment, order summary
app: core
path: /ecommerce/checkout_page
code_files: ["ecommerce/checkout_page.dart"]
---

## How it works

Material's `Stepper` walks through Shipping, Payment and Summary using one int, `_step`. `onStepContinue` and `onStepCancel` move it with `clamp(0, 2)`, so pressing Continue on Summary has no effect. The `TextField`s have no controllers or validation, which means nothing reads what the user types, and the `$75.98` order total is a fixed string.

## Adapting it

- Add a `TextEditingController` per field, or a `Form` per step, and validate inside `onStepContinue` before advancing.
- Check for `_step == 2` in `onStepContinue` and place the order there.
- Collect card details through your payment provider's SDK rather than the plain `Card Number` field.
