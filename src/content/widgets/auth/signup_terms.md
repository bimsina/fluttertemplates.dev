---
title: Sign Up
description: A Flutter sign up screen with a live password-strength meter and a terms-and-conditions checkbox.
app: core
path: /auth/signup_terms
code_files: ["auth/signup_terms.dart"]
---

## How it works

`_strength` scores `_password` from 0 to 4, one point each for length, uppercase, a digit and a symbol, then indexes `_labels` and `colors` for the meter. Create account stays disabled until `_canSubmit` is true: a name, an email matching `_emailPattern`, at least `_minStrength` and the ticked box. Submitting only shows a `SnackBar`, and the terms line is plain text.

## Adapting it

- Put your registration request in `_submit`.
- Tune `_minStrength`, and let your server make the final call on email and password rules.
- Build the `CheckboxListTile` title from `TextSpan`s with tap recognisers so Terms and Privacy Policy open.
