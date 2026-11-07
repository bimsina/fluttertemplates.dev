---
title: Chat History
description: A Flutter AI chat history list of past conversations with search, pinning, and timestamps.
app: core
path: /ai/chat_history
code_files: ["ai/chat_history.dart"]
---

## How it works

Conversations come from a const `_convos` list, split into `pinned` and `recent` by `where` calls in `build`, then laid out by `_sectionHeader` and `_tile` in one `ListView`. There's no state. The search field has no controller, tiles have no `onTap`, and the add button only shows a demo `SnackBar`, so what you get is the layout and none of the behaviour.

## Adapting it

- Give `_Convo` an id and a `DateTime`. `time` is a display string today, so it can't be sorted.
- Add `onTap` to the `ListTile` in `_tile` and push your chat screen with that id.
- Convert to a `StatefulWidget` and filter `_convos` from the search `TextField`, on the server if histories get long.
