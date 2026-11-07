---
title: Reset Password
description: A Flutter reset password screen with new-password and confirm-password fields and inline validation.
app: core
path: /auth/reset_password
code_files: ["auth/reset_password.dart"]
---

## How it works

Validation is all getters: `_hasLength`, `_hasNumber` and `_matches` derive from `_password` and `_confirm`, and `_valid` enables the button only when all three pass. Keystrokes reach state through `onChanged`, so the `_Rule` checklist updates live. One `_obscure` flag controls both fields. The subtitle's promise about previous passwords isn't checked anywhere, and submit passes the password to `onReset`, or shows a demo `SnackBar` without it.

## Adapting it

- Make your reset call from `onReset`, which can capture the emailed token.
- Add a rule by writing another getter, including it in `_valid`, and rendering a matching `_Rule`.
- Leave password-history checks to the server and show its error under the `TextField`s.
