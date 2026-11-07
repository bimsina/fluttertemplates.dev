---
title: Chatbot
description: A Flutter chatbot UI with a typing indicator, quick-reply chips, and message bubbles.
app: core
path: /ai/chatbot
code_files: ["ai/chatbot.dart"]
---

## How it works

Messages are `(String, bool)` records in `_messages`, and `_reply` is the single entry point: it adds the user's text, shows 'Bolt is typing…' and answers 800 ms later with a template echoing that text. The `ActionChip` quick replies call it directly. `_send` reads the `TextEditingController`, ignores blank input, clears the field and passes the text on, from both the send button and the keyboard.

## Adapting it

- Replace the `Future.delayed` in `_reply` with your support backend, and clear `_typing` on errors too.
- Return `_quickReplies` from the server if they should change as the conversation moves on.
