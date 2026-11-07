---
title: Welcome
description: A Flutter welcome screen with a brand hero, tagline, and get-started and sign-in call-to-action buttons.
app: core
path: /auth/welcome
code_files: ["auth/welcome.dart"]
---

## How it works

A stateless screen: a `LinearGradient` fills the screen, with an icon tile, heading and two buttons pushed apart by `Spacer`s. The gradient runs from `scheme.primary` to `gradientEnd`, the same colour blended 30% away from `onPrimary`, so all `onPrimary` text keeps at least its contrast against `primary` in light and dark themes. The buttons call `onGetStarted` and `onSignIn`, or show a demo `SnackBar` without them.

## Adapting it

- Pass `onGetStarted` and `onSignIn` that route to sign-up and login.
- Replace 'Welcome to Nimbus' and `Icons.bolt_rounded` with your own branding.
