---
title: Event List
description: A Flutter events discovery list with category filters and date and location metadata.
app: core
path: /events/event_list
code_files: ["events/event_list.dart"]
---

## How it works

Events are typed through a small immutable `_Event` class, and `ChoiceChip`s across the top select an index into `_filters`. `build` narrows `_events` to the entries whose `category` matches that chip, while index 0 shows everything. The search button shows a demo `SnackBar` and cards don't respond to taps.

## Adapting it

- Keep real `DateTime` values instead of preformatted `date` strings so events can be sorted.
- Connect the search `IconButton` to `showSearch` or your own search page.
- Add an empty state if a chip can match nothing, because `ListView.builder` would show a blank area.
