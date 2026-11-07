---
title: Marquee Text
description: A Flutter marquee that auto-scrolls long text horizontally in a continuous loop.
app: core
path: /animation/marquee_text
code_files: ["animation/marquee_text.dart"]
---

## How it works

`_Marquee` lays two copies of its text in a `Row` inside a non-scrollable `SingleChildScrollView`, each at least as wide as the viewport. A `Ticker` calls `_tick` every frame, which advances the offset by `velocity` times the seconds since the last frame, so speed is the same at any refresh rate. The offset wraps modulo one copy's width, where the view looks identical, so the loop is seamless.

## Adapting it

- Pass your own `text`, ending it with a separator so the join between copies reads cleanly.
- Set `velocity` in pixels per second.
- Short strings stay still, as `_tick` returns early when one copy fits the viewport.
