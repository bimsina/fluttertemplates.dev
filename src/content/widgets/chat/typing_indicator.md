---
title: Typing Indicator
description: A Flutter group chat typing indicator with staggered dots, stacked avatars and an app bar status that names who is typing.
app: core
path: /chat/typing_indicator
code_files: ["chat/typing_indicator.dart"]
---

`_TypingBubble` runs one repeating controller and offsets each dot's phase, so all three share a ticker and the dots both lift and darken as the wave passes. It has no dependencies on the screen and can be moved into any message list. The `_typing` list drives the avatars and `_typingLabel`, which collapses to a generic message past two people. Everything is scripted by `_simulateTyping`, which tracks its timers so they are cancelled on dispose. For a real chat, add names from your presence channel, remove them when a message arrives, and expire them after a few seconds of silence.
