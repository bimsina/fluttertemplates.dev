---
title: Sleep Tracker
description: A showcase of Flutter's sleep tracking functionality
app: core
path: /health/sleep_tracker
code_files: ["health/sleep_tracker.dart"]
---

## How it works

`maxHours` and `avgHours` are derived from `_sleepData` in `build`, and each weekly bar is a `FractionallySizedBox` scaled by `h / (maxHours + 1)` to leave headroom. `Last Night` passes the final `_sleepData` entry through `_formatHours`, so it reads 8h 30m. A `SingleChildScrollView` keeps everything reachable on short screens. The `Set sleep goal` tile has no `onTap`.

## Adapting it

- Feed `_sleepData` from HealthKit or Health Connect, and handle an empty list, because `reduce` throws on one.
- `_sleepData.last` assumes the list runs oldest to newest, so sort it before rendering.
