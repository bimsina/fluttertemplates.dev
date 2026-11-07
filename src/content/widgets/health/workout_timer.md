---
title: Workout Timer
description: A showcase of Flutter's workout timer functionality
app: core
path: /health/workout_timer
code_files: ["health/workout_timer.dart"]
---

## How it works

The countdown here is real. `Timer.periodic` decrements `_remaining` from `_totalSeconds`, `_display` formats it as mm:ss, and `_TimerRingPainter` fills the ring from elapsed time. `_startTimer` cancels any earlier timer and `dispose` cleans up. Despite the `HIIT Session` label there are no intervals, just one five-minute countdown.

## Adapting it

- Change `_totalSeconds`, or pass it through the `WorkoutTimer` constructor.
- For intervals, keep a list of work and rest durations and advance to the next when `_remaining` hits zero in `_startTimer`.
- Counting ticks can drift, so store an end `DateTime` and derive `_remaining` from it if accuracy matters.
