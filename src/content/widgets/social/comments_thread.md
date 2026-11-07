---
title: Comments Thread
description: Threaded comments with nested replies, bottom input
app: core
path: /social/comments_thread
code_files: ["social/comments_thread.dart"]
---

## How it works

`_comments` nests a `replies` list inside each map, shown one level deep with a left indent and `↳` prefix. Replies are plain strings, with no author. A `SafeArea` composer is docked below an `Expanded` list. `_send` ignores blank input, otherwise it appends to `_comments` as `You` and clears `_controller`. Nothing is saved.

## Adapting it

- Replace `_sampleComments` with a recursive class, with authors and timestamps on replies.
- Append in `_send` only after your API call succeeds.
- Show the user's avatar in the empty `CircleAvatar`.
