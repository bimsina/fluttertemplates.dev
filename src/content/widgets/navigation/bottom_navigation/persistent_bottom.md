---
title: Persistent Bottom Navigation
description: A Flutter persistent bottom navigation bar that keeps each tab's state when switching.
app: core
path: /navigation/bottom_nav/persistent_bottom
code_files: ["navigation/bottom_nav/persistent_bottom.dart"]
---

## How it works

Each tab gets its own `Navigator` inside an `IndexedStack`, so pushed pages survive tab switches and the bar stays visible. `PopScope` blocks back only while the active tab has a route to close, and `onPopInvokedWithResult` then pops that tab's navigator. At a tab root `canPop` is true, so the framework pops the page itself. A `NotificationListener<NavigationNotification>` keeps `canPop` current as tabs push and pop. `PersistentBottomNavPage` holds the keys in its `State`, so a parent rebuild keeps the stacks intact. `Page1` to `Page3` are demos.

## Adapting it

- Pass your screens as `tab` in `PersistentTabItem`.
- In `onTap`, pop to the first route when the active tab is tapped.
- Swap `BottomNavigationBar` for `NavigationBar` if you want Material 3 styling.
