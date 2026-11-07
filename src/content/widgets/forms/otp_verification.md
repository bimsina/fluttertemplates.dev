---
title: OTP Verification
description: Individual digit boxes, auto-focus, resend timer
app: core
path: /forms/otp/otp_verification
code_files: ["forms/otp/otp_verification.dart"]
---

## How it works

Six one-character `TextField`s share the `_controllers` and `_focusNodes` lists, each `Flexible` up to 44px wide, and `onChanged` moves focus forward after a digit and back after a deletion. `FilteringTextInputFormatter.digitsOnly` rejects anything else, and `_startResendTimer` runs the 30-second countdown on a `Timer.periodic` cancelled in `dispose`. Backspace on an already empty box fires no `onChanged`, so focus stays put. Verify shows an error until all six boxes are filled, then passes the code to `onVerify`, or a demo `SnackBar` without it. Resend only restarts the countdown.

## Adapting it

- Send the code to your auth API from `onVerify`.
- `maxLength: 1` truncates pasted codes, so spread pasted digits across `_controllers` if you need paste.
