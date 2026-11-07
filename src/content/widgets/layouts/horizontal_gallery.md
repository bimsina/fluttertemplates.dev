---
title: Horizontal Gallery
description: Snap-to-center cards with scaling animation
app: core
path: /layouts/horizontal_gallery
code_files: ["layouts/horizontal_gallery.dart"]
---

## How it works

A `PageView.builder` with `viewportFraction: 0.85` lets neighboring cards peek in. A listener on `_controller` copies the fractional page into `_currentPage`, and each card derives `scale` from its distance to that value, clamped to 0.85 to 1. The dot row uses the same value to mark the active page. Because the listener calls `setState` on every scroll tick, the whole page rebuilds during a drag.

## Adapting it

- Replace `_cards` with your data and put an image inside the `Card`.
- Move the scaling to an `AnimatedBuilder` on `_controller` for long or heavy lists.
- Adjust the `0.15` factor to change how far side cards shrink.
