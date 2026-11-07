---
title: Sectioned Settings Page
description: A Flutter settings page with grouped sections, toggles, and navigation rows.
app: core
path: /must_haves/settings_page/settings_page_1
code_files: ["must_haves/settings_page/settings_page_1.dart"]
---

## How it works

A list of four `_SingleSection` groups: General, Network, Privacy and Security, and Display and Sound. Each is an uppercase heading above a tinted `Material` block of `_CustomListTile`s, which keeps tile ink visible. `_CustomListTile` falls back to a chevron when it gets no `trailing`. Each `CupertinoSwitch` and its row toggle state, and Dark Mode restyles this page only. Other tile taps show a demo `SnackBar`.

## Adapting it

- Read `_wifi`, `_bluetooth` and `_darkMode` from a settings store, and connect Dark Mode to your app theme.
- Pass `onTap` to the remaining `_CustomListTile`s in place of the `_showDemo` fallback.
- Replace the sample rows with your app's own settings.
