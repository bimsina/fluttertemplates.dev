---
title: Profile Settings
description: User profile settings with photo, personal info, and preferences
app: core
path: /profile/profile_settings
code_files: ["profile/profile_settings.dart"]
---

## How it works

A stateful page holding `_pushNotifications`, `_language`, `_darkMode` and `_connected`. `Dark Mode` follows the app until switched, then `_pageTheme` restyles this page only. `Language` opens a `SimpleDialog` picker and shows the choice as its subtitle, though nothing gets translated. Tapping a connected account row toggles it in `_connected`, which drives `_accountBadge`. `_buildSettingTile` falls back to a chevron when no `trailing` is given. Edit Profile, Email and Phone show a demo `SnackBar`.

## Adapting it

- Feed `_language` into `MaterialApp.locale`, and persist it.
- Connect `Dark Mode` to your app-level theme state, removing `_pageTheme`.
- Start your OAuth flow from `_toggleAccount`, and route `Edit Profile` from its `onTap`.
