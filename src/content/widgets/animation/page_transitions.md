---
title: Page Transitions
description: Fade, slide, scale, and rotation transition showcase
app: core
path: /animation/page_transitions
code_files: ["animation/page_transitions.dart"]
---

## How it works

Four `_TransitionButton`s each push a `PageRouteBuilder` to the same `_DemoPage`, differing only in `transitionsBuilder`: `FadeTransition`, `SlideTransition`, `ScaleTransition` and `RotationTransition`. They run on the route's default duration with the raw linear `animation`, no curve applied. Passing `animation` straight to `turns` spins the page one full revolution on the way in, then backwards on pop.

## Adapting it

- Extract the repeated `PageRouteBuilder` into a helper taking a page and a transition, and call it from your router.
- Wrap `animation` in a `CurvedAnimation` for softer motion, and set `transitionDuration` to change timing.
- Replace `_DemoPage` with your destination screen.
