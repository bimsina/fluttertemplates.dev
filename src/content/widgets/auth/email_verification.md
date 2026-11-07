---
title: Email Verification
description: A Flutter email verification screen with a confirmation illustration and a resend-email option.
app: core
path: /auth/email_verification
code_files: ["auth/email_verification.dart"]
---

## How it works

`EmailVerification` is a `StatelessWidget` with the address alex@example.com baked into a `Text.rich`, and two `Spacer`s centre the `Column`. 'Open email app' and 'Resend email' call `onOpenEmailApp` and `onResendEmail`, or show a demo `SnackBar` without them. The screen also has no way of learning that verification happened, so a user who clicks the link stays here.

## Adapting it

- Add an email parameter to `EmailVerification` and use it in the `TextSpan`.
- Call your resend endpoint from `onResendEmail` with a cooldown, which requires a `StatefulWidget`.
- Poll your auth provider or listen for a deep link to move on, and handle `onOpenEmailApp` with a package such as open_mail_app.
