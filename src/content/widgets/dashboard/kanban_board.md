---
title: Kanban Board
description: A showcase of Flutter's kanban board functionality
app: core
path: /dashboard/kanban_board
code_files: ["dashboard/kanban_board.dart"]
---

## How it works

`_tasks` holds mutable copies of the const `_columns` lists. Each task is a `LongPressDraggable` and each column a `DragTarget`, so a held card can be dropped on another column, where `_moveTask` appends it. `EdgeDraggingAutoScroller` scrolls the board while a card is held near the screen edge, which keeps off-screen columns reachable. The Add button shows a demo `SnackBar`, and moves aren't saved.

## Adapting it

- Persist each move to your backend from `_moveTask`.
- Hook the `OutlinedButton.icon` up to a create-task dialog.
- `_moveTask` always appends, so work out an index from the drop position to support reordering.
