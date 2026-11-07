---
title: Masonry Grid
description: Pinterest-style staggered grid with varying heights
app: core
path: /layouts/masonry_grid
code_files: ["layouts/masonry_grid.dart"]
---

## How it works

Items go to the shortest column: `LayoutBuilder` walks `_items`, tracking estimated `heights` and collecting indexes in `columns`. Each column is a `Column` inside a `Row` with `spacing`, so horizontal and vertical gaps match. `_MasonryCard` sizes to its content rather than a fixed height, which leaves room for the title at any text size. Everything builds eagerly inside a `SingleChildScrollView`, and `crossAxisCount` is fixed at two.

## Adapting it

- Derive `crossAxisCount` from `constraints.maxWidth` for wider screens.
- Swap the colored block for images with known aspect ratios.
- Use `flutter_staggered_grid_view` to lazily build long lists.
