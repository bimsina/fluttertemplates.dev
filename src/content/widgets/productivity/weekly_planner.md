---
title: Weekly Planner
description: A Flutter weekly planner with a day strip, drag-to-reschedule tasks, open-task counts and a sheet for adding tasks by area.
app: core
path: /productivity/weekly_planner
code_files: ["productivity/weekly_planner.dart"]
---

Tasks keep a date and are filtered per day by `_tasksOn`, so moving one only means changing `task.day`. Each `_DayCell` is a `DragTarget` and each `_TaskTile` a `LongPressDraggable`, with a short delay so the list still scrolls normally. Dropping calls `_move`, which offers undo through a snackbar. Week navigation shifts the selected day by the same amount, keeping the same weekday in view. `_AddTaskSheet` returns a `_Task` from the modal instead of mutating state itself. Add areas by extending `_Area` and its label and icon getters, and replace `_seedTasks` with stored tasks for a real calendar.
