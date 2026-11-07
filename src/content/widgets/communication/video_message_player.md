---
title: Video Message Player
description: Video message bubbles with inline player and full-screen modal
app: core
path: /communication/video_message_player
code_files: ["communication/video_message_player.dart"]
---

## How it works

Thumbnails are gradients and nothing plays. Each bubble owns a position in `_progress`, and tapping one calls `_showVideoPlayer` with its index, opening a `showModalBottomSheet` with a play icon, slider and time labels. Those labels come from the message's `duration`, through `_parseSeconds` and `_formatSeconds`. A `StatefulBuilder` rebuilds the sheet's controls while the page's `setState` keeps the bubble behind in sync.

## Adapting it

- Give `_showVideoPlayer` a `VideoPlayerController` from video_player, disposed on close, and drive `_progress` from it.
- The `thumbnail` key in `_messages` is never read, so store a real image URL there and show it in `_buildVideoMessage`.
