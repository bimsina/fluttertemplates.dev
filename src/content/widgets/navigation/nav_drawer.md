---
title: Navigation Drawer
description: A Flutter navigation drawer with a profile header, grouped destinations, and a footer.
app: core
path: /navigation/nav_drawer
code_files: ["navigation/nav_drawer.dart"]
---

## How it works

Uses Material 3's `NavigationDrawer` with `selectedIndex`, closing via `Navigator.pop` after selection. Dividers and the header don't count as destinations, so `Sign out` is simply index 4 and gets highlighted like a page. A post-frame callback in `initState` opens the drawer automatically, purely so previews show it. The body never reacts to `_selected`.

## Adapting it

- Remove the `addPostFrameCallback` block before shipping.
- Branch in `onDestinationSelected`: if `i == 4`, run logout and don't store it in `_selected`.
- Render a page per `_selected` in `body`, and replace the `Alex Kim` header with the signed-in user.
