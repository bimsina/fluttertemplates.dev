---
title: Two-Factor Auth
description: A Flutter two-factor authentication screen with a six-digit code entry and a resend-code timer.
app: core
path: /auth/two_factor
code_files: ["auth/two_factor.dart"]
---

## How it works

A custom `_Keypad` feeds `_code`, capped at six digits, and `List.generate` draws a box per digit. The sixth digit calls `_submit`, which locks the keypad for 600 ms and compares against `_demoCode`, shown as a hint: a match turns the boxes green, a miss clears them with an error. `Timer.periodic` counts `_seconds` down from 30, and `_resend` resets it inside `setState` before restarting the timer. Boxes are `Flexible` for narrow phones, and `SliverFillRemaining` scrolls short screens.

## Adapting it

- Replace the `Timer` in `_submit` with your verification API, showing any error it returns, and remove `_demoCode`.
- Send the new code from `_resend`.
- Pass the masked number in. `_Keypad` can't receive pasted or autofilled codes, so consider a `TextField` with `AutofillHints.oneTimeCode`.
