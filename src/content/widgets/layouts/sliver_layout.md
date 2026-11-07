---
title: Sliver Layout
description: CustomScrollView with collapsing SliverAppBar and tabs
app: core
path: /layouts/sliver_layout
code_files: ["layouts/sliver_layout.dart"]
---

## How it works

`NestedScrollView` hosts a pinned, collapsing `SliverAppBar` and a pinned tab strip. `_SliverTabDelegate` adapts `TabBar` to `SliverPersistentHeader`, using its preferred height for both extents and painting a surface background so content doesn't show through. The three `_TabContent` lists are inline placeholders, driven by a manually created `_tabController`.

## Adapting it

- Replace the `Item A1` style lists passed to `_TabContent` with real data, keeping `length: 3` in sync with the tab count.
- Put an image in `FlexibleSpaceBar.background` in place of the gradient.
- Add `SliverOverlapAbsorber` in `headerSliverBuilder` if tab bodies become `CustomScrollView`s.
