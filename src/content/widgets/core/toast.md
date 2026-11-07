---
title: Toast & Snackbar
description: A showcase of Flutter's built-in toast messages and snackbars
app: core
path: /core/toast_demo
code_files: ["core/toast_demo.dart"]
---

## How it works

`_showSnackBar` is the single helper, taking `behavior`, `duration`, `backgroundColor`, `textColor` and an optional `action`. `textColor` is applied through a `TextStyle` on the content, so the 'Colored Snackbar' call really sets white text. 'Show Multiple' schedules three messages with `Future.delayed`, and `ScaffoldMessenger` queues them one after another instead of stacking. The Undo and Cancel actions only display a second snackbar.

## Adapting it

- Move `_showSnackBar` into a `BuildContext` extension so any screen can call it.
- Put your restore logic in the `SnackBarAction` `onPressed`, and call `hideCurrentSnackBar` first if new messages should replace old ones.
