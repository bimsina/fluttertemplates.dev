---
title: Collapsing App Bar
description: A Flutter collapsing sliver app bar that shrinks a hero header into a toolbar on scroll.
app: core
path: /navigation/sliver_app_bar
code_files: ["navigation/sliver_app_bar.dart"]
---

## How it works

`CollapsingAppBar` is a `CustomScrollView` containing a pinned `SliverAppBar` with `expandedHeight: 220`. `FlexibleSpaceBar` handles the title animation and collapse, with no scroll listeners needed. The background is a gradient with a faint landscape icon. Below it, a `SliverChildBuilderDelegate` generates 20 placeholder `ListTile`s, the favorite button toggles `_favorite`, and share shows a demo `SnackBar`.

## Adapting it

- Put an `Image` in `background`, and keep a dark overlay so the `Yosemite` title stays legible.
- Replace `childCount: 20` with your list length, and read items by index.
- Add `floating` and `snap` to `SliverAppBar` if the header should return on any upward scroll.
