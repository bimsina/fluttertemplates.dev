---
title: Animated Counter
description: Number roll/slide effect with AnimatedSwitcher
app: core
path: /animation/animated_counter
code_files: ["animation/animated_counter.dart"]
---

## How it works

`AnimatedSwitcher` does the work: `ValueKey(_count)` tells it each number is a new child, and `transitionBuilder` combines a `SlideTransition` from above with a `FadeTransition` over 300 ms. The outgoing number plays the same transition in reverse. Direction is fixed, so decrementing slides the same way as incrementing, and `_count` has no lower limit.

## Adapting it

- Extract the `AnimatedSwitcher` into a widget that takes a value, for cart totals and the like.
- To flip direction on decrement, keep the previous value and pick the `Tween` `begin` offset from it.
- Clamp the `_count--` handler if negative numbers make no sense for your screen.
