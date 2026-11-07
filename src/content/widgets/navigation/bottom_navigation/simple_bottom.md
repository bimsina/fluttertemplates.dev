---
title: "Bottom Nav"
description: A Flutter bottom navigation bar with icons for switching between primary views.
app: core
path: /navigation/bottom_nav/simple_bottom
code_files: ["navigation/bottom_nav/simple_bottom.dart"]
---

## How it works

A `BottomNavigationBar` with a live `DropdownButton` for trying each `BottomNavigationBarType`, stored in `_bottomNavType`. The dropdown has no `value`, so it displays the current name through `hint`. With `shifting`, unselected labels hide and a tap animates the change. Colors are hardcoded, and the body only prints the current label.

## Adapting it

- Delete the dropdown and set `type` directly once you've chosen a style.
- Replace `Color(0xff6200ee)` with `Theme.of(context).colorScheme.primary`.
- Swap the centered `Column` for pages indexed by `_selectedIndex`.
