---
title: Event List
description: A showcase of Flutter's event list functionality
app: core
path: /calendar/event_list
code_files: ["calendar/event_list.dart"]
---

## How it works

`EventList` maps a const `_events` list of string maps into `Card`-wrapped `ListTile`s through `ListView.builder`. Every row gets the same blue `Icons.event` tile, and the 'Today' title is a literal with no date logic behind it. Row taps and the Add button show a demo `SnackBar`.

## Adapting it

- Replace the maps with a typed event class holding a `DateTime`, which removes casts like `e['title'] as String`.
- Load `_events` per day through a `FutureBuilder` or your state layer, and filter by the selected date.
- Colour the tile by event category instead of `Colors.blue`, and open a detail screen from `onTap` in place of `_showDemo`.
