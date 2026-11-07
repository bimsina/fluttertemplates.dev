---
title: Smart Light Control
description: A Flutter smart light control with a brightness slider and a color picker.
app: core
path: /iot/light_control
code_files: ["iot/light_control.dart"]
---

## How it works

Three fields hold the state: `_on`, `_brightness` and `_colorIndex`. The bulb is a circular `Container` whose fill and `BoxShadow` use `glow` with brightness as the alpha, so dragging the slider fades the halo. Switching off clears the shadow and disables the `Slider` by passing it a null `onChanged`. The state stays local, with no bulb on the other end.

## Adapting it

- Call your bulb API from the app bar `Switch`, the `Slider` and the swatch `onTap`.
- Edit `_colors` to match the presets your hardware supports, or add a color wheel.
- Set `_brightness` and `_on` from device state on load instead of the current defaults.
