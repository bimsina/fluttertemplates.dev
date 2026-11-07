---
title: Simple Settings Page
description: A Flutter settings screen with a simple list of preferences and switches.
app: core
path: /must_haves/settings_page/settings_page_2
code_files: ["must_haves/settings_page/settings_page_2.dart"]
---

## How it works

The one live control is `_isDark`. Its `Switch` swaps a `Theme` wrapped around this page between `ThemeData.dark()` and `ThemeData.light()`, so only this subtree changes and the rest of the app stays as it was; your custom theme is discarded here too. `_SingleSection` accepts a null `title`, which is how the last group renders headerless. Tapping the Dark Mode row toggles it. Other rows go through `_openRow`, which calls `onRowTap` with the title, or shows a demo `SnackBar` without it.

## Adapting it

- Remove the local `Theme` and push `_isDark` to app-level state feeding `MaterialApp.themeMode`.
- Persist `_isDark` with `shared_preferences`.
- Handle `Sign out` in `onRowTap` to run your auth logout.
