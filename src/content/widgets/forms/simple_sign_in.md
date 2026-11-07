---
title: "Sign In Form"
description: "A clean and straightforward sign-in form with essential fields and validation. Perfect for applications requiring a minimal authentication interface."
code_files: ["forms/sign_in/sign_in_page1.dart"]
path: "/forms/sign_in/sign_in_page1"
order: 2
icon: mdi:login
---

## How it works

Everything sits in one elevated `Card`, capped at 350px by `BoxConstraints`, with a `SingleChildScrollView` inside so the form stays reachable on short screens. `_SignInPage1State` tracks `_isPasswordVisible` and `_rememberMe`, and validators require a matching email and at least six password characters. A valid form then lands on a `/// do something` comment, and with no controllers the values are never captured.

## Adapting it

- Add controllers, call your auth service at that comment, and disable the `ElevatedButton` while it runs.
- The email `RegExp` only checks format, so confirm the address on your server.
- Replace `FlutterLogo` and `Welcome to Flutter!` with your branding, and persist `_rememberMe`.
