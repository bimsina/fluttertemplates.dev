---
title: Voice Call Screen
description: Audio-only call UI with mute, speaker, and hold controls
app: core
path: /communication/voice_call
code_files: ["communication/voice_call.dart"]
---

## How it works

The one live element is the pulse: `_pulseController` scales the avatar ring between 1.0 and 1.15 through `_pulseAnimation`, whatever the call state. Mute, speaker and hold all update their icons, with hold showing `Icons.pause` until the call is held and `Icons.play_arrow` to resume. No audio connection exists, and '00:45:32' and 'Sarah Johnson' are literals.

## Adapting it

- Stop `_pulseController` while `_isOnHold` is true.
- Call your VoIP SDK where `_isMuted`, `_isSpeakerOn` and `_isOnHold` flip in `setState`.
- Hang up in the End `_buildActionButton` before `Navigator.pop`.
