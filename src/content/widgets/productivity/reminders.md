---
title: Reminders
description: A Flutter reminders screen with scheduled tasks grouped by day and toggle switches.
app: core
path: /productivity/reminders
code_files: ["productivity/reminders.dart"]
---

## How it works

`_groups` nests mutable `_Reminder` objects inside `_Group` sections, rendered with collection `for` loops spreading a header and tiles into one `ListView`. A `Switch` flips `r.on` directly in `setState`. Nothing is scheduled, though: `time` is display text such as `'9:30 AM'` or `'Thu'`, and the add button shows a demo `SnackBar`. Sections are fixed labels, not computed dates.

## Adapting it

- Store a `DateTime` in `_Reminder`, and derive `_Group` labels from it.
- Schedule or cancel with `flutter_local_notifications` from the `Switch` `onChanged`.
- Open a creation form from the `FloatingActionButton`, and persist `_groups`.
