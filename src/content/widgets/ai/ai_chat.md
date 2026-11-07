---
title: AI Chat
description: A Flutter AI chat UI with simulated streaming replies, user and bot bubbles, and an input bar.
app: core
path: /ai/ai_chat
code_files: ["ai/ai_chat.dart"]
---

## How it works

Replies are simulated, and the screen says so: no model is called. `_send` appends the user's `_Msg`, then `_simulatedTokens` emits the same canned reply word by word from a `Stream.periodic`, growing `_partialReply` while the list follows it. `_TypingDots` shows until the first token. The send button becomes stop while streaming, which keeps the partial text, and `dispose` cancels the subscription.

## Adapting it

- Replace `_simulatedTokens` with your provider's token stream, and remove the demo caption.
- Add an `onError` to the `listen` call, because a simulated stream can't fail but yours can.
