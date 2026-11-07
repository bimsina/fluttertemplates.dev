---
title: Admin Dashboard
description: A showcase of Flutter's admin dashboard functionality
app: core
path: /dashboard/admin_dashboard
code_files: ["dashboard/admin_dashboard.dart"]
---

## How it works

The four entries in the top-level `_metrics` list render as cards inside a `Wrap`. `LayoutBuilder` picks four columns above 600px of available width and two below, then sizes each card with `tileWidth`, leaving its height to the content. Change labels are colored by whether the string starts with `+`, and every number, including both Recent Activity rows, is hardcoded.

## Adapting it

- Replace `_metrics` with a typed model loaded from your API, using a `FutureBuilder` around the `Wrap`.
- Build the two activity `ListTile`s from a list instead of writing each one by hand.
