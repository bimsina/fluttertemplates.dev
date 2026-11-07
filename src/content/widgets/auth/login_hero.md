---
title: Login Screen
description: A Flutter login screen with a hero illustration, validated email and password fields, remember-me, and sign-in callbacks.
app: core
path: /auth/login_hero
code_files: ["auth/login_hero.dart"]
---

## How it works

`_remember` drives the `Checkbox` and `_obscure` the password visibility toggle. `_signIn` validates the `Form` (an email-shaped address and a non-empty password), then calls `onSignIn` with the trimmed email and password. 'Forgot password?' and 'Sign up' call `onForgotPassword` and `onSignUp`. All three are optional, and each shows a demo `SnackBar` when omitted, so nothing is authenticated by default. The hero is a tinted `Container` holding an icon, not an image.

## Adapting it

- Call your auth service from `onSignIn`.
- Track a loading flag around that call, disable the `FilledButton` during it, and show failures inline.
- `_remember` isn't stored anywhere, so use it to decide whether the session token persists.
