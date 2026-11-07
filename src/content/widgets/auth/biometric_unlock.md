---
title: Biometric Unlock
description: A Flutter biometric unlock screen with Face ID and fingerprint prompts and a passcode fallback.
app: core
path: /auth/biometric_unlock
code_files: ["auth/biometric_unlock.dart"]
---

## How it works

Nothing touches a biometric API. `_scan` sets `_scanning`, waits 1200 ms with `Future.delayed`, then always succeeds by setting `_unlocked`, so no failure state exists. The `AnimatedContainer` ring and status `Text` react to those two booleans, and taps are ignored while scanning or once unlocked. 'Use passcode instead' calls `onUsePasscode`, or shows a demo `SnackBar` without it.

## Adapting it

- Replace the delay in `_scan` with `LocalAuthentication().authenticate()` from local_auth, plus that package's platform setup.
- Add an error flag beside `_unlocked` for failed or cancelled attempts.
- Navigate away on success instead of stopping at `Icons.lock_open_rounded`, and point `onUsePasscode` at your PIN screen.
