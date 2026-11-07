---
title: Pomodoro Timer
description: A Flutter pomodoro timer with a CustomPaint progress ring, focus and break modes, round tracking and adjustable durations.
app: core
path: /productivity/pomodoro_timer
code_files: ["productivity/pomodoro_timer.dart"]
---

Remaining time comes from a `Stopwatch` plus a banked duration rather than counting ticks, so the display stays right when a browser throttles the periodic timer. `_bank` freezes elapsed time on pause and before any speed change. When a round ends, `_finish` records it and picks the next mode, with a long break after every `_roundsPerCycle` focus rounds, then offers to start it from a snackbar. Durations are edited in the settings sheet, which also has a 60x preview for watching the full cycle. Remove that switch for production, and persist `_completedRounds` and `_focusedMinutes` if the daily totals should survive a restart.
