---
title: Message Input
description: A Flutter chat composer with an attachment tray, upload progress tiles, a growing text field and send blocked until uploads finish.
app: core
path: /chat/message_input
code_files: ["chat/message_input.dart"]
---

Pending files live in `_pending`, and `_canSend` stays false while any attachment is below full progress, so a message can never go out with a half-uploaded file. Each upload runs on a `Timer` stored by id, which lets `_remove` cancel it and `dispose` clean up. To connect real storage, replace the periodic timer in `_attach` with your upload stream and write to `attachment.progress`, and swap `_sampleNames` for a file picker result. The limit is the `_maxAttachments` constant. `_ComposerField` grows to five lines before scrolling, and the tray uses `AnimatedSize` so it pushes the composer up instead of covering messages.
