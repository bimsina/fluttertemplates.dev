---
title: Activity Feed
description: Timeline with vertical connector, activity icons
app: core
path: /social/activity_feed
code_files: ["social/activity_feed.dart"]
---

## How it works

Rows form a vertical timeline. `IntrinsicHeight` lets the connector line, an `Expanded` `Container`, stretch to match the row, and it's skipped on the final item. Entries in `_activities` only hold an icon and text, so nothing says who acted or when. The dot color indexes `Colors.primaries` with a modulo, so it repeats on long lists.

## Adapting it

- Add actor, timestamp and target fields to `_activities` before connecting a feed.
- Map colors from the activity type instead of the row index.
- Watch `IntrinsicHeight` costs on long lists; a fixed row height would avoid the extra layout pass.
