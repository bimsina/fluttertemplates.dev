---
title: Material 3 Bottom Navigation
description: A Flutter Material 3 NavigationBar with icons, labels, and a selected indicator.
app: core
path: /navigation/bottom_nav/material3_bottom
code_files: ["navigation/bottom_nav/material3_bottom.dart"]
---

## How it works

Standard `NavigationBar` with `NavigationDestination`s defined in a top-level const list. Each destination pairs an outline `icon` with a filled `selectedIcon`. `animationDuration` is set to one full second, which feels slow beside the framework default. `_selectedIndex` only changes the `Selected Page` text in the body, as there are no page widgets.

## Adapting it

- Reduce or delete `animationDuration`.
- Build a pages list aligned with `_navBarItems`, and show it with `IndexedStack`.
- Wrap the `Icons.shopping_bag_outlined` icon in `Badge` to show a cart count.
