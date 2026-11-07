---
title: World Clock
description: Multiple timezone clock display with day/night indicators
app: core
path: /utilities/world_clock
code_files: ["utilities/world_clock.dart"]
---

## How it works

`_cities` holds fixed UTC offsets in minutes, so half-hour zones like Mumbai work. `_scheduleTick` sets a `Timer` for the next minute boundary and reschedules itself, cancelled in `dispose`. `_buildLocationCard` derives `isDay` from each city's local hour, with 6:00 to 18:00 as day, which drives the gradient and icon. Daylight saving is not modelled: offsets never change, so New York, London and Paris run an hour off in summer, and Sydney in its winter. The add and menu buttons show a demo `SnackBar`.

## Adapting it

- Use the `timezone` package with IANA names in place of `offsetMinutes`.
- Connect the `Icons.add` button to a city picker.
- Pass `now` in tests to control the clock.
