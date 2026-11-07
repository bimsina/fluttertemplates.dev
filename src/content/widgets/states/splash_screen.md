---
title: Splash Screen
description: Animated logo scale-in, name fade-in, loading indicator
app: core
path: /states/splash_screen
code_files: ["states/splash_screen.dart"]
---

## How it works

One `AnimationController` drives two overlapping `Interval`s: `_scaleAnimation` over the first 60% and `_fadeAnimation` over the last 60%, so the logo pops before the title fades in. There's no completion handling, so the screen stays forever with its spinner running. The logo background reads `primaryColor` while the icon uses `onPrimary`, which aren't always a matched pair.

## Adapting it

- Add a status listener to `_controller`, and navigate when both animation and app init finish.
- Replace `Icons.flutter_dash` and `App Name` with your branding.
- Use `colorScheme.primary` for the logo box, and configure native splash separately.
