---
title: Split View
description: Master-detail layout, collapses to single pane on mobile
app: core
path: /layouts/split_view
code_files: ["layouts/split_view.dart"]
---

## How it works

`LayoutBuilder` switches at 600px. Wide screens get a folder list, email list and detail `Card` side by side; narrow screens run `_buildNarrowLayout`, which swaps between list and detail and drops the folders. Tapping an email sets `_selectedEmail` and `_showDetail` on both layouts, so a closed detail pane reopens. One gap remains: `_selectedIndex` highlights a folder but `_emails` never changes.

## Adapting it

- Filter or fetch `_emails` by `_selectedIndex`.
- Replace the nested `AppBar` in `_buildNarrowLayout` with a pushed route so the system back gesture works.
- Load the message body for `_selectedEmail` in place of the placeholder text.
