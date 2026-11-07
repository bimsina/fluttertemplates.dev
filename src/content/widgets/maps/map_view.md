---
title: Map View
description: A Flutter map view UI with location markers, a floating search bar, and a recenter button.
app: core
path: /maps/map_view
code_files: ["maps/map_view.dart"]
---

## How it works

A full-screen `Stack` layers `_MapPainter`, which draws park, water and road shapes, under floating UI. `_Pin` markers use fixed pixel offsets through `Positioned`, so they have no geographic meaning and won't track screen size. The search bar is a `Row` holding a `Text`, not an input. `Blue Fig Bistro` is a hardcoded result card, and the recenter and `Go` actions show a demo `SnackBar`.

## Adapting it

- Swap `_MapPainter` and the `_Pin` widgets for map SDK tiles and markers fed by lat/lng data.
- Put a `TextField` where `Search here` sits, or navigate to a search screen on tap.
- Update the bottom `Card` when a marker is selected.
