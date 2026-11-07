---
title: Activity Log
description: A Flutter admin activity log with a timeline of user actions, actors, and timestamps.
app: core
path: /admin/activity_log
code_files: ["admin/activity_log.dart"]
---

## How it works

`ActivityLog` is stateless and reads a const `_events` list of six entries, with times stored as ready-made strings like '2 min ago'. Each row is an `IntrinsicHeight` `Row`, which lets the connector line stretch to the height of the text beside it, and `isLast` drops the line on the final entry. The filter button in the app bar shows a demo `SnackBar`.

## Adapting it

- Load `_events` from your audit API and make `_Event.time` a `DateTime` formatted at render time, so entries don't go stale.
- Derive `_Event.icon` from an event type instead of setting it by hand per row.
- Use the `Icons.filter_list` button's `onPressed` to open a filter by actor or action.
