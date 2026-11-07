---
title: Workout List
description: A showcase of Flutter's workout list functionality
app: core
path: /health/workout_list
code_files: ["health/workout_list.dart"]
---

## How it works

Four `_workouts` flow through `ListView.builder`, each tile showing the same `fitness_center` icon and a subtitle joining `duration`, `calories` and `date`. Relative dates such as `2 days ago` are stored strings, so they would go stale in real use. Tiles have no tap action, and the `FloatingActionButton.extended` shows a demo `SnackBar`.

## Adapting it

- Store a `DateTime` in place of `date` and format the relative text at render time.
- Map workout type to an icon instead of always using `Icons.fitness_center`.
- Use the FAB's `onPressed` to open an entry form, then add the result to a stateful list.
