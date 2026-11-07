---
title: Month Calendar
description: A showcase of Flutter's month calendar functionality
app: core
path: /calendar/month_calendar
code_files: ["calendar/month_calendar.dart"]
---

## How it works

`_displayedMonth` starts on the current month, and the grid is computed from real dates: `DateTime(year, month, 1).weekday - 1` gives the leading blanks, `DateTime(year, month + 1, 0).day` the month length, and the cell count rounds up to full weeks. The chevrons move a month and select its first day. `_events` is sample data keyed by `DateTime`, placed around today, and the agenda card lists whatever falls on `_selectedDate`.

## Adapting it

- Replace `_events` with your own data, normalising keys to midnight so lookups match.
- Swap `_monthNames` for intl's `DateFormat` if you need localised labels.
- Replace `_showDemo` in each agenda `ListTile`'s `onTap` with your event screen.
