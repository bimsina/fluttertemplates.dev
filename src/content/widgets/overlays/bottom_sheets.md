---
title: Bottom Sheets
description: Simple, form, draggable, and nested scrolling variants
app: core
path: /overlays/bottom_sheets
code_files: ["overlays/bottom_sheets.dart"]
---

## How it works

Three private helpers wrap `showModalBottomSheet`. `_showFormSheet` sets `isScrollControlled` and pads by `viewInsets.bottom` so fields clear the keyboard. `_showDraggableSheet` passes the `DraggableScrollableSheet` controller to its `ListView`, letting scroll and resize cooperate, with `expand: false` so it sizes inside the modal. The form's `TextField`s have no controllers, so `Submit` only closes the sheet.

## Adapting it

- Add controllers in `_showFormSheet`, and return values through `Navigator.pop(ctx, data)`.
- Tune `initialChildSize`, `minChildSize` and `maxChildSize` for your content.
- Pass `showDragHandle: true` to `showModalBottomSheet` in place of the hand-drawn handle.
