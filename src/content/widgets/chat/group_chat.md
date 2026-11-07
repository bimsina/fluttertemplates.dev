---
title: Group Chat
description: A showcase of a simple group chat UI in flutter
app: core
path: /chat/group_chat
code_files: ["chat/group_chat.dart"]
---

## How it works

`ChatService` is a local simulation exposing broadcast streams for messages and typing. `_simulateResponses` picks one to three random `users` and echoes your text after 1 to 3 seconds. Each reply is a `Timer` in `_pendingReplies`, and `typingStream` emits the users still holding one, so overlapping replies stay correct. `dispose` cancels those timers before closing the controllers. `_TypingDots` loops on a repeating `AnimationController`.

## Adapting it

- Replace `sendMessage` and `_simulateResponses` with your socket client, keeping `messageStream` and `typingStream` as the interface.
- Render `timestamp`, which is recorded but never displayed.
