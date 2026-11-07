---
title: Music Player
description: A showcase of Flutter's music player functionality
app: core
path: /media/music_player
code_files: ["media/music_player.dart"]
---

## How it works

There's no audio backend: `_playing` flips the play and pause icon, and `_progress` belongs to a `Slider` that never advances on its own. The `1:24` and `4:12` labels are fixed strings. Skip buttons cycle `_tracks` and reset `_progress`, and queue shows a demo `SnackBar`. A `LayoutBuilder` puts the artwork beside the controls on short landscape screens and above them otherwise, and a centered `SingleChildScrollView` keeps everything reachable.

## Adapting it

- Connect `_playing` to a player such as `just_audio`, and start or pause in the `onPressed`.
- Feed `_progress` from the position stream, and seek in the `Slider` `onChanged`.
- Compute the `1:24` and `4:12` labels from position and duration.
