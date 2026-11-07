---
title: Photo Grid
description: A showcase of Flutter's photo grid functionality
app: core
path: /gallery/photo_grid
code_files: ["gallery/photo_grid.dart"]
---

## How it works

There is no backing data at all: `itemCount: 12` is a literal, and each cell is a tinted `Container` with a `photo` icon, colored by a `Colors.primaries` modulo. The grid has square cells with 4px gaps. The `grid_view` action switches `_columns` between three and two, and tapping a tile does nothing.

## Adapting it

- Introduce a list of URLs, set `itemCount` from it, and return an image with `BoxFit.cover` from `itemBuilder`.
- Save `_columns` so the layout choice persists.
- Wrap the `Container` in a `GestureDetector` to open a full-screen viewer.
