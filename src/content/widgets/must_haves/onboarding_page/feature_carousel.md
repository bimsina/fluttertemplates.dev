---
title: Feature Carousel
description: A Flutter onboarding feature carousel highlighting app benefits with auto-advancing slides.
app: core
path: /must_haves/onboarding_page/feature_carousel
code_files: ["must_haves/onboarding_page/feature_carousel.dart"]
---

## How it works

`Timer.periodic` advances `_controller` every three seconds with `animateToPage`, wrapping with a modulo, so the jump from the last card to the first scrolls back across all of them. `onPageChanged` keeps `_page` and the `AnimatedContainer` dots in sync. The timer isn't paused during a manual swipe, so it can tug the page mid-gesture. `dispose` cancels it correctly, and `Continue` shows a demo `SnackBar`.

## Adapting it

- Cancel `_timer` on user interaction, for example from a `NotificationListener` around the `PageView.builder`.
- Replace `_features`, especially claims like encryption that your app must actually meet.
- Navigate onward from the `FilledButton`.
