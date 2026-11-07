---
title: Magic Link Login
description: A Flutter passwordless login screen that emails a magic sign-in link, with a sent-confirmation state.
app: core
path: /auth/magic_link
code_files: ["auth/magic_link.dart"]
---

## How it works

`_sent` swaps the `Column` between a request view and a 'Check your inbox' view. `_send` checks the `TextEditingController`'s text against `_emailPattern`: a bad address sets `_emailError` under the field, and a good one flips `_sent` straight away, with the confirmation naming that address. No email actually goes out.

## Adapting it

- Await your provider's request, such as Supabase `signInWithOtp` or Firebase `sendSignInLinkToEmail`, in `_send` and set `_sent` only on success.
- Nothing in `MagicLink` handles the return trip, so register a deep link handler to complete sign-in.
