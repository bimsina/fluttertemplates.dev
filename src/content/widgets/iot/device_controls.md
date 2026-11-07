---
title: Device Controls
description: A Flutter IoT device controls screen with toggle cards for lights, plugs, and sensors.
app: core
path: /iot/device_controls
code_files: ["iot/device_controls.dart"]
---

## How it works

`_toggles` is a name-to-bool map that drives a `SwitchListTile` per device; icons are picked by comparing the key to `'Lamp'` and `'Fan'`. `_SliderCard` is reused for `_brightness` and `_fanSpeed`, showing each 0 to 1 value as a percentage. Nothing links the controls: turning off the lamp leaves its slider active, and no device is contacted.

## Adapting it

- Send commands to your hub from the `onChanged` callbacks, and debounce the sliders with `onChangeEnd` on `Slider`.
- Move `_toggles` to a device model that holds its own icon, removing the string comparison.
- Pass a null `onChanged` to `_SliderCard` when its device is off.
