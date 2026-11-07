---
title: Google Bottom Bar
description: A Flutter bottom navigation bar with a Google-style pill indicator and labels.
app: core
path: /navigation/bottom_nav/google_bottom_bar
code_files: ["navigation/bottom_nav/google_bottom_bar.dart"]
---

## How it works

`SalomonBottomBar` from the `salomon_bottom_bar` package provides the pill animation where the active item expands to show its label. `_selectedIndex` is the only state. The body is a neat shortcut: it reuses `_navBarItems[_selectedIndex].title`, so no pages exist yet. Each item's `selectedColor` takes priority over the bar's purple `selectedItemColor`.

## Adapting it

- Replace the `Center` body with an `IndexedStack` of real pages so tab state survives switching.
- Change `selectedColor` per item, or remove it to use one accent.
- Swap the hardcoded `unselectedItemColor` for a theme value if you support dark mode.
