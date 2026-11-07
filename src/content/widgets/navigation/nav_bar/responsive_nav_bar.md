---
title: Responsive Navigation Bar
description: A Flutter responsive navigation bar with app bar links on wide screens and a drawer on narrow ones.
app: core
path: /navigation/nav_bar/responsive_nav_bar
code_files: ["navigation/nav_bar/responsive_nav_bar.dart"]
---

## How it works

`MediaQuery` width above 800 shows `_navBarItems` inline in the `AppBar`; below that, a menu button opens `_drawer`, both built from `_menuItems`. Links, drawer rows and the `_ProfileIcon` menu all call `_select`, which stores `_selected`, highlights the match, updates the body text and shows a demo `SnackBar`. The drawer closes itself first. `ThemeData.dark()` is forced on the whole page, overriding your app theme.

## Adapting it

- Remove the `Theme` wrapper, or supply your own dark theme.
- Turn `_menuItems` into label and route pairs, then navigate from `_select`.
- Rename the `Menu` values, and update the `switch` in `_ProfileIcon`.
