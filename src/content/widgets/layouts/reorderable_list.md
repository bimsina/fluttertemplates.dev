---
title: Reorderable List
description: Drag handles with ReorderableListView
app: core
path: /layouts/reorderable_list
code_files: ["layouts/reorderable_list.dart"]
---

## How it works

`_items` holds five strings shown through `ReorderableListView.builder`, each `Card` carrying the required `ValueKey`. `onReorderItem` already adjusts `newIndex` for the removed item, so the callback only removes and inserts. `Icons.drag_handle` is decorative, since it isn't wrapped in a drag listener: mobile users long-press a row, and desktop gets the default trailing handle.

## Adapting it

- Wrap the icon in `ReorderableDragStartListener` and set `buildDefaultDragHandles: false`.
- Persist `_items` order after each drop, because it resets when the page is recreated.
- Use unique IDs in `ValueKey`, as duplicate titles would collide with strings as keys.
