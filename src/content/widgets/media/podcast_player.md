---
title: Podcast Player
description: A Flutter podcast player with an episode list and simulated playback, a seek bar, and play/pause.
app: core
path: /media/podcast_player
code_files: ["media/podcast_player.dart"]
---

## How it works

Playback is simulated, and the page labels it: there's no audio. `_current` tracks the episode, while a one-second `Timer.periodic` advances `_position`, cancelled in `dispose`. The `Now Playing` tile shows the current episode with a play/pause button, and a `Slider` seeks. Tapping an episode starts it from zero, and playback stops at the end. `Icons.download` is a bare icon rather than a button.

## Adapting it

- Parse `_episodes` from your RSS feed, keeping a real date type for sorting.
- Replace the timer in `_play` with your audio plugin's position stream.
- Change the trailing `Icon` to an `IconButton` that starts a download.
