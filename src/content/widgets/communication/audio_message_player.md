---
title: Audio Message Player
description: Chat-style audio message bubbles with play/pause and seek functionality
app: core
path: /communication/audio_message_player
code_files: ["communication/audio_message_player.dart"]
---

## How it works

No audio plays. Each bubble has its own position in `_progress`, and `_playingIndex` tracks the one playing message, so starting another pauses the first. Nothing advances `_progress` on its own, though each `Slider` moves its own bubble. `_buildAudioMessage` shows the `sender` above the player, with the duration and `timestamp` below the slider.

## Adapting it

- Drive `_progress` from a player such as just_audio, and seek from the `Slider`'s `onChanged`.
- Turn the `_messages` maps into a typed model with a URL, and read `audioDuration` from the file.
