---
title: Todo List
description: A Flutter to-do list with add, check-off, swipe-to-delete, and remaining-count.
app: core
path: /productivity/todo_list
code_files: ["productivity/todo_list.dart"]
---

## How it works

One of the more complete demos. `_add` trims input, ignores blanks and inserts at the top; swiping a `Dismissible` deletes, and `ObjectKey(t)` keeps duplicate text safe. `_remaining` recomputes for the app bar line, which reads "1 tasks" for a single task. Tasks exist only in memory, and because `bottomSheet` overlaps the body, it can cover the final rows of a long list.

## Adapting it

- Persist `_tasks` with `sqflite` or `hive` by adding an ID to `_Task`.
- Add bottom padding to `ListView.builder` to clear the input bar.
- Offer undo through a `SnackBar` in `onDismissed`.
