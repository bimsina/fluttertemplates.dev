---
title: Account Settings
description: Account management with security, privacy, and subscription options
app: core
path: /profile/account_settings
code_files: ["profile/account_settings.dart"]
---

## How it works

A stateless page assembled from `_buildHeader`, `_buildSection` and `_buildSettingTile`, with `isDark` passed manually through every call to pick greys. Section color has a special case, `title == 'Danger Zone'`, comparing against the display string. All values such as `'1.2 GB'` and `'3 users'` are literals, and every `onTap` shows a demo `SnackBar`. The header says `Free Plan` while the plan row mentions a trial.

## Adapting it

- Pass an account model into `AccountSettings`, and bind each `subtitle` to it.
- Confirm with a dialog in the `Delete Account` `onTap` before calling your API.
- Replace `isDark` branches with `colorScheme.onSurfaceVariant`, which removes the parameter.
