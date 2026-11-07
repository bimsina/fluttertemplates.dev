---
title: Error 404
description: Large 404, playful design, Go Home button
app: core
path: /states/error_404
code_files: ["states/error_404.dart"]
---

## How it works

Layout only: a large `404` in `displayLarge`, using the theme's primary color, over two lines of explanation and a `Go Home` button. With no `AppBar` there's no back arrow, and the button only shows a demo `SnackBar`, leaving users on this screen. Nothing connects it to your router yet.

## Adapting it

- Register `Error404` as your `go_router` `errorBuilder`, or as `onUnknownRoute` on `MaterialApp`.
- Replace `_showDemo` in `onPressed` to return to your home route, clearing the stack.
- Accept the failed path as an `Error404` parameter if you want to log it.
