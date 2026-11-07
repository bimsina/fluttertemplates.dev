---
title: Smart Home
description: A Flutter smart home dashboard with rooms, device cards, and quick scene controls.
app: core
path: /iot/smart_home
code_files: ["iot/smart_home.dart"]
---

## How it works

`_devices` is a mutable list of `_Device` objects laid out in a two-column `GridView.count`, nested in a `ListView` with `shrinkWrap` and scrolling disabled. Flipping a `Switch` mutates `on` in place, recoloring the `_DeviceCard` and updating `activeCount`. The room row uses plain `Chip`s with no selection, so it filters nothing. The greeting and `21°C` are hardcoded.

## Adapting it

- Swap `Chip` for `ChoiceChip`, hold the selected room in state, and filter `_devices` on `room` before building the grid.
- Have `onToggle` call your hub and roll back on failure.
- Wire the `Icons.add` button to a pairing flow.
