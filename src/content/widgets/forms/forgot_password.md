---
title: Forgot Password
description: Email input, success state, back to login
app: core
path: /forms/forgot_password/forgot_password
code_files: ["forms/forgot_password/forgot_password.dart"]
---

## How it works

A single boolean, `_sent`, switches the body between `_buildForm` and `_buildSuccessState`. `_submit` runs the `TextFormField` validator, which rejects empty and malformed addresses, before setting `_sent`. No request is made, so the success screen is only a demonstration. Both Back to Login buttons call `onBackToLogin`, or show a demo `SnackBar` without it.

## Adapting it

- Await your reset call in `_submit` before setting `_sent`.
- Track a loading flag next to `_sent` to disable the button while the request runs.
- Soften the copy in `_buildSuccessState` to "if an account exists" so the page can't be used to discover registered emails.
