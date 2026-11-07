---
title: Activity Timeline
description: A Flutter CRM activity timeline of calls, emails, and notes with timestamps.
app: core
path: /crm/activity_timeline
code_files: ["crm/activity_timeline.dart"]
---

## How it works

Each `_Activity` bundles its own `icon`, `color`, `title`, `detail` and `time`, so colour coding is per entry rather than derived from a type. `ListView.builder` lays out rows with `IntrinsicHeight`, letting an `Expanded` connector fill the space under the icon circle until `isLast`. The five entries are const demo data with pre-written timestamps, and rows can't be tapped.

## Adapting it

- Introduce an activity type enum and map it to `icon` and `color`, so API responses only need the type.
- Replace `_items` with data for one contact, taking its id in the `ActivityTimeline` constructor.
- `IntrinsicHeight` adds a layout pass per row, so paginate long feeds.
