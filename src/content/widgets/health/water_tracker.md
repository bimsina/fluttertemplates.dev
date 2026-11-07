---
title: Water Tracker
description: A showcase of Flutter's water tracking functionality
app: core
path: /health/water_tracker
code_files: ["health/water_tracker.dart"]
---

## How it works

The `_goal` constant and the `_current` field drive everything: `List.generate` draws filled or outlined `water_drop` icons, and `LinearProgressIndicator` shows their ratio. Add Glass increments `_current`, and disables itself at the goal. The icons sit in a `Wrap`, which moves them onto a second line on narrow phones. A centered `SingleChildScrollView` holds the column, so landscape phones and large text scroll instead of overflowing.

## Adapting it

- Add an undo control if users need to correct a mistaken tap.
- Save the count per date, for instance with `shared_preferences`, so `_current` restarts each day.
