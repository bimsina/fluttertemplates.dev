---
title: "Simple Chat UI"
description: "A showcase of a simple chat UI in flutter"
app: core
path: /chat/simple_chat
code_files: ["chat/simple_chat.dart"]
---

## How it works

Bubbles are driven by two broadcast streams on a local `ChatService`, which `_SimpleChatState` listens to in `initState`. There's no network: `_simulateResponse` waits 1 to 3 random seconds and returns 'This is a simulated response to' plus your text. Replies are `Timer`s in `_pendingReplies`, so typing stays on until the last lands, and `dispose` cancels them. `_scrollToBottom` uses a post-frame callback so `maxScrollExtent` includes the new bubble.

## Adapting it

- Feed `messageStream` and `typingStream` from your backend in place of `_simulateResponse`.
- Replace `isMe` with a sender id if more than two people can talk.
- Render `timestamp`, which is recorded but never displayed.
