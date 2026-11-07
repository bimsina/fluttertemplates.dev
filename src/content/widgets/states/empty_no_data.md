---
title: Empty - No Data
description: Icon, message, and CTA button empty state variant
app: core
path: /states/empty_no_data
code_files: ["states/empty_no_data.dart"]
---

## How it works

The most minimal of the state screens: a centered `Column` with an outline-colored `Icons.inbox_outlined`, heading, sentence and button. It's stateless with no logic, and `Add Item` shows a demo `SnackBar`. Having its own `Scaffold` and `AppBar` means it's a full page, not a drop-in list placeholder.

## Adapting it

- Drop the `Scaffold`, leaving the `Center`, so it can render inside an existing page body.
- Add constructor parameters for icon, title, message and an `onPressed` action.
- Hide the `FilledButton.icon` when the viewer can't create items.
