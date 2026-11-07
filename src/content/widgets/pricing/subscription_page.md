---
title: Subscription Page
description: A showcase of Flutter's subscription page functionality
app: core
path: /pricing/subscription_page
code_files: ["pricing/subscription_page.dart"]
---

## How it works

`_interval` and `_selectedPlan` track a `SegmentedButton` and a `RadioGroup`. `RadioGroup` owns the group value, so each `RadioListTile` only declares its own `value`. Prices are ternaries on `_interval` written directly in the subtitles, with `save 17%` shown only for Pro though Enterprise has the same discount. `Continue` shows a demo `SnackBar`.

## Adapting it

- Move prices to a plan model, and calculate the `save 17%` figure instead of typing it.
- Start checkout from `Continue` using `_selectedPlan` and `_interval`.
- Replace the string keys `'pro'` and `'ent'` with an enum.
