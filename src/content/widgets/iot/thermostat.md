---
title: Thermostat
description: A Flutter thermostat control with a circular temperature dial and a mode selector.
app: core
path: /iot/thermostat
code_files: ["iot/thermostat.dart"]
---

## How it works

`_DialPainter` draws a 270-degree arc from `startAngle`, filling `sweep * t` where `t` normalizes `_target` between `_min` and `_max`, then places a knob at the end. Tapping or dragging the dial runs `_setTargetFrom`, which converts position to an angle and rounds to whole degrees; drags can't jump across the bottom gap. `_mode` sets the arc color and, compared with the fixed `_current` reading, the `Heating`, `Cooling` or `Idle` status. Nothing reaches a real device.

## Adapting it

- Send `_target` and `_mode` to your device, debouncing rapid changes.
- Replace `_current` with a live sensor value.
- Read the size from a `LayoutBuilder` if you change the 240px dial.
