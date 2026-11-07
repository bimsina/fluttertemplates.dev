---
title: Assignment List
description: A showcase of Flutter's assignment list functionality
app: core
path: /education/assignment_list
code_files: ["education/assignment_list.dart"]
---

## How it works

One derived flag, `isSubmitted`, does most of the work here: it sets the avatar color and swaps between check and assignment icons, while the `Chip` prints the raw status. Items come from the const `_assignments` list via `ListView.builder`. Due dates are plain strings, so nothing sorts them or flags overdue work, and the sample isn't in date order. `onTap` shows a demo `SnackBar`.

## Adapting it

- Store `due` as a `DateTime`, then sort by it and add an overdue state.
- Replace the `status` string with an enum so a typo can't silently fall into the pending styling.
- Use `onTap` to open the assignment's detail or submission page.
