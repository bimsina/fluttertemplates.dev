---
title: Conference Call
description: Multi-participant video conferencing grid with mute and controls
app: core
path: /communication/conference_call
code_files: ["communication/conference_call.dart"]
---

## How it works

`_participants` is a fixed list of five maps, rendered as a two-column `GridView.builder` of avatar tiles with no video. `_buildParticipantTile` draws a green border for `isSpeaking` and a red badge for `isMuted`, but those flags never change. Your own `_isMuted` and `_isSpeakerOn` toggles only swap icons and labels, and the red pill's '12:34' is a literal.

## Adapting it

- Feed `_participants` from an RTC SDK such as LiveKit, mapping active-speaker events to `isSpeaking`.
- In `_buildParticipantTile`, replace the gradient `Container` with the SDK's video view.
- Leave only calls `Navigator.pop`, so disconnect from the room first, then connect the Invite and Chat `_buildControlButton` callbacks.
