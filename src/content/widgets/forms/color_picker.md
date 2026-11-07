---
title: Color Picker
description: A Flutter HSV color picker with a saturation box, hue and opacity sliders, validated hex input, presets and recent colors.
app: core
path: /forms/color_picker
code_files: ["forms/color_picker.dart"]
---

`HSVColor` is the source of truth, so hue survives when saturation or brightness reaches zero, which a round trip through RGB would lose. `_SvPainter` layers a white-to-hue gradient under a transparent-to-black one, and `_TrackPainter` draws both sliders, adding a checkerboard behind opacity. `_KeyboardControl` makes the box and sliders tab stops with arrow keys and a focus ring, and `Semantics` adds increase and decrease actions. The hex field accepts three or six digits, and typing there never rewrites it. `onColorChanged` fires on every change. Replace `_presets` with your brand palette, and change `_commit` to return the color from a dialog instead of copying it.
