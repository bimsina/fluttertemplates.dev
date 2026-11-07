---
title: Habit Tracker
description: A Flutter habit tracker with tappable week rows, computed streaks, week navigation and undoable habit removal.
app: core
path: /productivity/habit_tracker
code_files: ["productivity/habit_tracker.dart"]
---

Each `_Habit` stores completed days as a set of date-only values, so a toggle is one set operation and streaks are computed instead of stored. `streak` walks backwards from today, or from yesterday when today is still open, so an unfinished day does not reset the count. Dates go through `_addDays`, which uses calendar arithmetic to avoid daylight saving drift. Weeks start on Monday, future days are disabled, and navigation stops at the current week. To persist habits, serialize `done` as ISO dates. Weekly or custom schedules would need a per-habit list of active weekdays that `streak` skips over.
