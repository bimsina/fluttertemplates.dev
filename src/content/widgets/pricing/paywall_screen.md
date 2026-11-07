---
title: Paywall Screen
description: A showcase of Flutter's paywall screen functionality
app: core
path: /pricing/paywall_screen
code_files: ["pricing/paywall_screen.dart"]
---

## How it works

A non-scrolling `Column`: a 240px hero block, benefit rows generated from an inline list, a subscribe button and `Maybe later`. The latter is the only live control, calling `Navigator.of(context).pop()`. Subscribing only shows a demo `SnackBar`, and `$19/month` is baked into the label. Because nothing scrolls, smaller phones can overflow at the bottom.

## Adapting it

- Connect the `FilledButton` to `in_app_purchase` or RevenueCat, and take price text from the store product.
- Add a restore purchases `TextButton`, which store reviewers expect.
- Wrap the lower `Padding` in a `SingleChildScrollView`.
