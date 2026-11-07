---
title: Social Login
description: A Flutter social login screen with Google, Apple, and email sign-in buttons and an or-divider.
app: core
path: /auth/social_login
code_files: ["auth/social_login.dart"]
---

## How it works

`SocialLogin` is layout only, with no OAuth in it. `_SocialButton` wraps an `OutlinedButton` around an icon and label. All three call `onProviderSelected` with 'google', 'apple' or 'email', and 'Create a new account' calls `onCreateAccount`, with a demo `SnackBar` when either is omitted. Google is represented by `Icons.g_mobiledata_rounded`, a stand-in glyph and not the brand mark.

## Adapting it

- Start sign-in from `onProviderSelected`, using google_sign_in and sign_in_with_apple or your auth provider's SDK.
- Replace the `icon` field with an image parameter so you can use official logos, as Google and Apple both publish branding rules.
- Make `SocialLogin` stateful and add a busy flag, because OAuth takes seconds and double taps are easy.
