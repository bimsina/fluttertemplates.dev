---
title: Video Call Screen
description: Full-screen video call UI with controls for mute, camera, speaker, and ending call
app: core
path: /communication/video_call
code_files: ["communication/video_call.dart"]
---

## How it works

There's no camera or WebRTC code. The remote video is a `LinearGradient` behind a `CircleAvatar`, the self-view is a grey box, and '00:45:32' never ticks. `_isMuted`, `_isVideoOn` and `_isSpeakerOn` update the UI. `_isFrontCamera` switches the Flip button's icon, and the self-view's tint, icon and Front or Rear caption, so flipping is visible.

## Adapting it

- Replace the background `Container` with a remote renderer and the `Positioned` box with a local preview, for example `RTCVideoView` from flutter_webrtc.
- Call your SDK inside each `_buildControlButton` `onTap`, such as switching cameras from Flip.
- Run the duration from a `Timer.periodic`, and pass the caller's name into `VideoCallScreen`.
