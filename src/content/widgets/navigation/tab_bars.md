---
title: Tab Bar
description: A Flutter tab bar with swipeable views plus a scrollable and a segmented-control variant.
app: core
path: /navigation/tab_bars
code_files: ["navigation/tab_bars.dart"]
---

## How it works

Two selectors on one screen. `DefaultTabController` links the `TabBar` to the `TabBarView` with no manual controller, while a `SegmentedButton` writes `_segment`. That value reaches each `_GridTab` as `period`, which shows a third of `count` for Day, two thirds for Week and all of it for Month. `_GridTab` fills a three-column `GridView.count` with placeholder tiles, so the fraction stands in for a real date filter.

## Adapting it

- Replace the fraction in `_GridTab` with a real date filter.
- Replace the `List.generate` tiles with real media thumbnails.
- If you don't need a period filter, delete `_segment` and go stateless.
