---
title: Video Player
description: A Flutter video player UI with simulated playback, a seek bar, and play/pause controls.
app: core
path: /media/video_player
code_files: ["media/video_player.dart"]
---

## How it works

There is no video here, just a black 220px `Container` labelled `Simulated playback`, with controls overlaid in a `Stack`. A one-second `Timer.periodic` advances `_position` while playing, stops at `_duration`, and is cancelled in `dispose`. The `Slider` and time label both read `_position`, so dragging seeks. Tapping the surface or the small icon toggles playback, and the large center icon hides while playing. The fullscreen button shows a demo `SnackBar`.

## Adapting it

- Rename the `VideoPlayer` class before adding the `video_player` package, which exports the same name.
- Render the package's player in the `Container`, calling play and pause in `_togglePlaying`.
- Sync `_position` from the controller and remove the timer.
