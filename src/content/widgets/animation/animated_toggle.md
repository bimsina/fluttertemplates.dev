---
title: Animated Toggle
description: Custom switch with color morphing and icon transitions
app: core
path: /animation/animated_toggle
code_files: ["animation/animated_toggle.dart"]
---

## How it works

Three implicit animations share the `_on` flag: `AnimatedContainer` changes the track colour, `AnimatedAlign` moves the thumb, and `AnimatedSwitcher` crossfades the check and close icons, all over 200 ms. Only the thumb has a curve, so the colour shift runs linearly beside it. A bare `GestureDetector` handles taps, which leaves no focus, keyboard or screen-reader support.

## Adapting it

- Extract the `GestureDetector` subtree into a widget with `value` and `onChanged` parameters so `_on` lives with the caller.
- Wrap it in `Semantics` with `toggled` set from `_on`.
- Replace `primaryColor` with `colorScheme.primary`, which tracks Material 3 schemes.
