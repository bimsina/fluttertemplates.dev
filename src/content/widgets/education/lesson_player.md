---
title: Lesson Player
description: A showcase of Flutter's lesson player functionality
app: core
path: /education/lesson_player
code_files: ["education/lesson_player.dart"]
---

## How it works

Playback is simulated: no video loads, and the play button runs a one-second `Timer` that advances `_positions` toward `_lessonSeconds`. The `Slider` seeks, the percentage and clock derive from the position, and the timer stops at the end or on `dispose`. Previous and Next switch between `_lessons`, pause playback and keep each lesson's position.

## Adapting it

- Put a player from the `video_player` package where the gray `Container` is, creating its controller in `initState` and disposing it.
- Update `_positions` from that controller instead of `_tick`.
- Pass lesson data into `LessonPlayer` to replace the hardcoded `_lessons`.
