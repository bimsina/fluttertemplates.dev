---
title: Notifications Feed
description: Follow/like/comment notifications with unread dots
app: core
path: /social/notifications_feed
code_files: ["social/notifications_feed.dart"]
---

## How it works

`_notifications` holds a user, a type and an unread flag; `Stack` adds a blue dot on unread avatars. `_message` switches on `type` and returns a full sentence, such as `Bob liked your post`, with a generic fallback for unknown types. `'2h ago'` is hardcoded on every row. Rows aren't tappable, so the unread dots never clear.

## Adapting it

- Move the sentences in `_message` to your localization files.
- Store timestamps and format relative time to replace `'2h ago'`.
- Add `onTap` to the `ListTile` to mark read and open the source post.
