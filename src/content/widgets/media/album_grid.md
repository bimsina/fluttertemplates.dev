---
title: Album Grid
description: A showcase of Flutter's album grid functionality
app: core
path: /media/album_grid
code_files: ["media/album_grid.dart"]
---

## How it works

`GridView.builder` lays out `_albums` in two columns, or four when `MediaQuery` reports a width above 600. Each `Card` has a colored block standing in for cover art, tinted from `Colors.primaries` with a modulo, and a name and artist below. Cards aren't tappable, and tints repeat on lists longer than the palette.

## Adapting it

- Replace the placeholder `Container` with `Image.network`, and clip it to the card's top corners.
- Add `InkWell` around each `Card` to open the album.
- Swap `SliverGridDelegateWithFixedCrossAxisCount` for the max-extent delegate if column count should scale without a single breakpoint.
