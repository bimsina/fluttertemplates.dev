---
title: Shimmer Loading
description: Skeleton loading with animated gradient sweep
app: core
path: /animation/shimmer_loading
code_files: ["animation/shimmer_loading.dart"]
---

## How it works

A 1500 ms repeating `AnimationController` drives `_animation` from 0 to 1, and each `_ShimmerBox` turns that into a highlight band placed in pixels, using the screen width and its own measured width. Every box shares a left edge, so one 240 px band crosses them all at the same speed, whatever their size. Only each box's `AnimatedBuilder` rebuilds per frame.

## Adapting it

- Show the `_ShimmerCard`s while your future is pending, since the demo never resolves to content.
- Match `_ShimmerBox` sizes to your real layout, and take `baseColor` and `highlightColor` from the theme.
- Boxes that don't start at the same x need their offset added to `bandStart` to stay in line.
