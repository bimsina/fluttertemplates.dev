---
title: Staggered List
description: Items animate in one-by-one with slide and fade
app: core
path: /animation/staggered_list
code_files: ["animation/staggered_list.dart"]
---

## How it works

One 800 ms `AnimationController` runs once from `initState`, and each row gets its own `Interval` starting at `index * 0.1` with a 0.2 window, so rows fade and slide in one after another. The sixth row finishes at 0.7, leaving the last 30% idle. `initState` builds the `CurvedAnimation`s and slide tweens once, `dispose` releases them, and `FadeTransition` and `SlideTransition` listen for themselves.

## Adapting it

- Replace `_items` with your data, rebuilding `_animations` and `_slides` if its length changes, and call `_controller.forward(from: 0)` to replay after a refresh.
- `delay.clamp` caps starts at 0.9, so rows from the tenth onward animate together.
