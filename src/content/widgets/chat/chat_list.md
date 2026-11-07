---
title: Chat List
description: A Flutter inbox of conversations with search, unread and group filters, pinned chats, muting and a long-press actions sheet.
app: core
path: /chat/chat_list
code_files: ["chat/chat_list.dart"]
---

`_visible` applies the filter chip and search query, then sorts pinned chats first while keeping the original order as a tie-breaker. Muted chats keep a neutral badge and are left out of the unread total in the app bar, matching how most messengers behave. Opening a chat clears its unread count and pushes `_ThreadPage`, which is a placeholder for your conversation screen. Actions live in one bottom sheet, reached by long press or right click, and each goes through the local `act` helper so the sheet closes before state changes. Replace `_chats` with your data source, and move the mutable `_Chat` fields into your store.
