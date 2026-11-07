---
title: DM List
description: Conversations with avatar, last message, unread badge
app: core
path: /social/dm_list
code_files: ["social/dm_list.dart"]
---

## How it works

Two entries from `_conversations` go through `ListView.builder`. A `Stack` in `leading` overlays a 12px blue badge when `unread` is true, and the name turns bold. The badge digit `'1'` and timestamp `'2m'` are hardcoded, so neither comes from the data. `ListTile` has no `onTap`, so rows can't open a chat.

## Adapting it

- Use a conversation model with `unreadCount` and a `DateTime`, replacing the `'1'` and `'2m'` literals.
- Add `onTap` to the `ListTile` to push your chat screen.
- Feed `_conversations` from a stream so new messages reorder the list.
