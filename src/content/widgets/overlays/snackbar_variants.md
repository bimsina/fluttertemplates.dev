---
title: Snackbar Variants
description: Simple, action, icon, error, and persistent snackbar styles
app: core
path: /overlays/snackbar_variants
code_files: ["overlays/snackbar_variants.dart"]
---

## How it works

Four `FilledButton`s each call `ScaffoldMessenger.of(context).showSnackBar` with a different configuration: plain, with a `SnackBarAction`, with a green icon row, and error-colored. Repeated taps queue up rather than replacing the current bar, since nothing hides it first. The `Undo` callback only confirms with another `SnackBar`, and the success color is hardcoded while the error one comes from the theme.

## Adapting it

- Call `hideCurrentSnackBar` before `showSnackBar` if newer messages should win.
- Put your restore logic in `onPressed` on `SnackBarAction`.
- Wrap these in one helper taking the message and type, and replace `Colors.green` with a theme extension color.
