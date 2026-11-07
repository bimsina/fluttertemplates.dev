---
title: Date Range Picker
description: A showcase of Flutter's date range picker functionality
app: core
path: /calendar/date_range_picker
code_files: ["calendar/date_range_picker.dart"]
---

## How it works

Two `ListTile`s each call `showDatePicker` and store the result in `_start` or `_end`. The end picker uses `_start` as its `firstDate`, and picking a start after the current end clears `_end`, so the range can't invert. Apply Range stays disabled until both dates are set, then passes a `DateTimeRange` to `onApply`, or shows a demo `SnackBar` without it. `_format` prints dates as month/day/year.

## Adapting it

- Consider a single `showDateRangePicker` in place of both `showDatePicker` calls, since it returns a validated `DateTimeRange`.
- Return the range with `Navigator.pop` from `onApply`, and format with intl's `DateFormat`.
