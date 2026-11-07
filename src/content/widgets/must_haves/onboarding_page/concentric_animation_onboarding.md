---
title: Concentric Animation Onboarding
description: A Flutter onboarding flow with animated concentric color transitions between slides.
app: core
path: /must_haves/onboarding_page/concentric_animation_onboarding
code_files: ["must_haves/onboarding_page/concentric_animation_onboarding.dart"]
---

## How it works

Built on the `concentric_transition` package: `ConcentricPageView` supplies the expanding circle wipe, taking its colors from `pages`. Since `itemCount` is commented out, the carousel loops forever, with `index % pages.length` mapping back to the three `PageData` entries. There's no finish callback here. `_Page` scales icon and text from screen height, inverting `bgColor` and `textColor` for the icon badge.

## Adapting it

- Uncomment `itemCount` to stop the looping, then add a route to your home screen after the last page.
- Edit `pages` for your own copy, colors and icons.
- Try the other commented options, such as `direction`.
