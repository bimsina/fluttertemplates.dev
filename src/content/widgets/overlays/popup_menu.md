---
title: Popup Menu
description: PopupMenuButton, MenuAnchor, and long-press context menu
app: core
path: /overlays/popup_menu
code_files: ["overlays/popup_menu.dart"]
---

## How it works

Three menu APIs side by side: `PopupMenuButton` in the app bar and body, `MenuAnchor` opened by hand through its controller, and `showMenu` on long press, awaited for its result. Every choice goes through `_choose`, which updates the `Last choice` line. The context menu is positioned with a fixed `RelativeRect`, so it opens in the same spot regardless of where you press.

## Adapting it

- Switch from `onLongPress` to `onLongPressStart` and build the `RelativeRect` from `globalPosition`.
- Replace `_choose` with your real actions, preferably keyed by an enum instead of raw strings.
