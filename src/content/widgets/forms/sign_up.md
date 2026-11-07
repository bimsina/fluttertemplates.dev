---
title: Sign Up
description: Registration with password strength indicator
app: core
path: /forms/sign_up/sign_up_page
code_files: ["forms/sign_up/sign_up_page.dart"]
---

## How it works

`_passwordStrength` awards a point each for 8+ characters, an uppercase letter, a digit and a symbol, and a `ValueListenableBuilder` on `_passwordController` shows `strength / 4` as a bar. Email must match `_emailPattern`, and Confirm Password must equal `_passwordController.text`. `_submit` passes the trimmed email and password to `onSubmit` once `validate()` passes, or shows a `SnackBar` without it.

## Adapting it

- Call your registration API from `onSubmit`, and disable the button while it runs.
- The bar is informational: any 8 characters pass, so check `_passwordStrength` in the validator to enforce a policy.
- `_emailPattern` only checks format, so confirm ownership with a verification email.
