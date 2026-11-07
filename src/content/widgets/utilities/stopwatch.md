---
title: Stopwatch
description: Full-featured stopwatch with start/stop, lap tracking, and time display
app: core
path: /utilities/stopwatch
code_files: ["utilities/stopwatch.dart"]
---

## How it works

Dart's `Stopwatch` measures elapsed time, so accuracy doesn't depend on timer ticks; `Timer.periodic` only repaints every 30ms. `_format` shares one `mm:ss.hh` layout between the dial and lap rows. Each `_Lap` stores its split and the running total, and rows show the split. A `LayoutBuilder` sizes the dial from the space left, up to 280px, with `FittedBox` scaling the time, so the lap panel fits on small phones. Nothing is persisted.

## Adapting it

- Show `lap.total` beside the split if you want cumulative times too.
- Highlight the fastest and slowest laps from `_laps`.
- Save a start timestamp to survive the page closing.
