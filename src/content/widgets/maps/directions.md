---
title: Directions
description: A Flutter turn-by-turn directions screen with a route summary and a step-by-step list.
app: core
path: /maps/directions
code_files: ["maps/directions.dart"]
---

## How it works

Two stacked regions: a primary-colored summary header and a `ListView.separated` of `_turns`, each a `_Turn` holding icon, instruction and distance in meters. It's entirely static. `_formatDistance` labels each row, and the `4.6 km` header total is summed from the same `_turns`, so they always agree. `18 min` is still a string literal, and `Start` and `Steps` show a demo `SnackBar`.

## Adapting it

- Build `_turns` from a Directions or Mapbox response, mapping each maneuver type to an `Icons.turn_*` icon.
- Derive the `18 min` header text from the same route response.
- Use the `Start` button to enter turn-by-turn mode, or hand off to a maps app.
