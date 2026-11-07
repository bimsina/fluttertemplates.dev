---
title: Audio Visualizer
description: An animated audio visualizer with simulated levels and a play/pause toggle.
app: core
path: /media/audio_visualizer
code_files: ["media/audio_visualizer.dart"]
---

## How it works

The bars are simulated, no audio is involved, and the page says so. An `AnimationController` repeats every two seconds, and `_level` mixes two sine waves with a per-bar phase, using whole wave counts so the loop is seamless. `AnimatedBuilder` rebuilds only the bar `Row`, with height and opacity following each level. The pause button stops the controller, and the label switches between `Playing...` and `Paused`.

## Adapting it

- Replace `_level` with amplitude or FFT data exposed by your audio plugin.
- Drive `_togglePlaying` from your player's state.
- Use `AnimatedContainer` for smoothing if data arrives slower than the frame rate.
