---
title: Playlist View
description: A showcase of Flutter's playlist view functionality
app: core
path: /media/playlist_view
code_files: ["media/playlist_view.dart"]
---

## How it works

A `CustomScrollView` with three slivers: a colored 180px banner, a title block, and a `SliverList` over `_tracks`. The song count is derived from `_tracks.length`, while durations are preformatted strings. Tapping a row stores it in `_playing`, which highlights that `ListTile` through `selected`; no audio plays.

## Adapting it

- Replace the `_tracks` maps with a track model, storing duration as a `Duration`.
- Start your player from `onTap`, and clear `_playing` when playback stops.
- Show the playlist's cover in the banner `Container` instead of `Icons.queue_music`.
