---
title: Stories Bar
description: Instagram-style story circles with feed below
app: core
path: /social/stories_bar
code_files: ["social/stories_bar.dart"]
---

## How it works

A horizontal `ListView.builder` inside a 116px `SizedBox`, with the first slot treated as "add your story" through `i == 0`. That height covers the 8px list padding, 72px avatar, gap and label. Tints index `Colors.primaries` with a modulo, so longer lists are safe. There's no story viewer, seen state or tap handling, and the feed below is filler.

## Adapting it

- Raise the `SizedBox` height if you enlarge `radius: 36`.
- Wrap each `CircleAvatar` in `GestureDetector` to open a viewer.
- Add a gradient ring for unseen stories, driven by your data instead of `_users`.
