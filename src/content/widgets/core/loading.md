---
title: Loading Indicators
description: A showcase of Flutter's built-in loading indicators and spinners
app: core
path: /core/loading
code_files: ["core/loading_demo.dart"]
---

## How it works

A catalogue of indicators in one scrolling `Column`. `LoadingDemo` is stateful but holds no state, and the `RefreshIndicator` only waits two seconds. Both overlays go through `_showTimedDialog`, which keeps its `DialogRoute` and closes that route after a fake delay, so the timer can't pop the page if back already dismissed the dialog. 'Skeleton Loading' is static `Container`s with no shimmer, coloured from `colorScheme` for dark mode.

## Adapting it

- Replace the `Future.delayed` in `_showTimedDialog` with your own future, closing the route in a `finally`.
- Point `onRefresh` at your reload and return its future.
