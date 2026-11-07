---
title: Dialogs
description: Confirmation, input, multi-choice, loading, and custom dialogs
app: core
path: /overlays/dialogs
code_files: ["overlays/dialogs.dart"]
---

## How it works

Four dialogs from `showDialog`, each awaited so its result appears in the `Last result` tile. `_NameDialog` owns its `TextEditingController` and disposes it after the closing animation, and `_MultiChoiceDialog` keeps a `Set` of `CheckboxListTile` choices until `Done`. `_showLoadingDialog` is a mock: `Future.delayed` closes it after two seconds, with `barrierDismissible: false` blocking outside taps and `PopScope` blocking back, so the timed `pop` can't close the page.

## Adapting it

- Act on each awaited result instead of calling `_showResult`.
- Replace `Future.delayed` with your real request, popping the dialog in a `finally`.
- Pass the options into `_MultiChoiceDialog` as a parameter.
