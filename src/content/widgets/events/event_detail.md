---
title: Event Detail
description: A Flutter event detail screen with a gradient header, date and venue rows, and a tickets button.
app: core
path: /events/event_detail
code_files: ["events/event_detail.dart"]
---

## How it works

A `CustomScrollView` with a pinned gradient `SliverAppBar` holds the content, while the price and Get tickets button sit in `bottomSheet`, so they stay on screen while scrolling. A 100px `SizedBox` at the end keeps text from hiding behind that sheet. The `_row` helper keeps date, venue and price lines consistent. Event details are inline strings. Follow toggles `_following`, and Get tickets shows a demo `SnackBar`.

## Adapting it

- Pass an event model into `EventDetail`, replacing literals such as `Indie Nights Live`.
- Swap the gradient `Container` for a cover image, which also removes the fixed `0xFF7E57C2`.
- Retune `SizedBox(height: 100)` if the bottom bar grows taller.
