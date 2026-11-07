---
title: Responsive Sign In
description: A responsive sign-in form that adapts to different screen sizes, with a clean layout and form validation.
code_files: ["forms/sign_in/sign_in_page2.dart"]
path: "/forms/sign_in/sign_in_page2"
order: 1
icon: mdi:login-variant
---

## How it works

`SignInPage2` reads `MediaQuery` width and stacks `_Logo` above `_FormContent` below 600px; wider screens get them side by side in a `Row` capped at 800px. Both layouts sit in a `SingleChildScrollView`, so short screens can scroll when the keyboard opens. `_FormContent` owns the `Form`, the password toggle and `_rememberMe`. A valid submit reaches a `/// do something` comment, so no one is signed in.

## Adapting it

- Add email and password controllers, and call your auth service at the `/// do something` comment.
- The email `RegExp` only checks format, so confirm the address on your server.
