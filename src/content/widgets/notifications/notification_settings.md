---
title: Notification Settings
description: A showcase of Flutter's notification settings functionality
app: core
path: /notifications/notification_settings
code_files: ["notifications/notification_settings.dart"]
---

## How it works

Three booleans, `_push`, `_email` and `_marketing`, each bound to a `SwitchListTile`. Toggles respond immediately but live only in memory, so they revert to defaults when the page is recreated. Below the divider, `Quiet Hours` is a static `ListTile` with a fixed time range and a demo `SnackBar` on tap.

## Adapting it

- Load initial values in `initState`, and save from each `onChanged` to `shared_preferences` or your API.
- When `_push` is switched on, request OS notification permission and revert if it's denied.
- Use `showTimePicker` in the `Quiet Hours` `onTap`, then render the stored times.
