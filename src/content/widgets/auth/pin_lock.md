---
title: PIN Lock
description: A Flutter PIN lock screen with a numeric keypad and animated dot indicators.
app: core
path: /auth/pin_lock
code_files: ["auth/pin_lock.dart"]
---

## How it works

`_tap` appends digits to `_pin`, and on the fourth waits 250 ms before comparing against the hardcoded '1234', also shown as a hint. Input is ignored during that wait. A wrong PIN sets `_error` and clears the dots. A right one sets `_unlocked`, turning the screen green with a check icon and a 'Lock again' button. `SliverFillRemaining` pins the fixed-height keypad low and scrolls on short screens.

## Adapting it

- Replace the `entered == '1234'` check with a salted hash from secure storage or a server call, and drop the hint.
- Navigate onward where `_unlocked` is set, and add an attempt counter with a lockout.
- Pass `onUseBiometrics` to start your biometric prompt. Without it, the button shows a `SnackBar`.
