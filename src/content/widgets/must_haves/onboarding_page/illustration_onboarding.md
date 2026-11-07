---
title: Illustration Onboarding
description: A Flutter onboarding flow with illustrated slides, page dots, and skip and next controls.
app: core
path: /must_haves/onboarding_page/illustration_onboarding
code_files: ["must_haves/onboarding_page/illustration_onboarding.dart"]
---

## How it works

A three-slide `PageView.builder` where `_page` drives the pill-shaped dots and the `_isLast` getter flips the button label from `Next` to `Get started`. Advancing uses `nextPage` with a 300ms ease. On the final slide the button calls `_exit`, as `Skip` does from any slide, and that only shows a `SnackBar`, so the flow has no real destination yet. The controller is disposed properly.

## Adapting it

- Replace `_exit` with navigation to your first real screen, saving a "seen" flag.
- Give `Skip` and `Get started` different destinations if your flow needs it.
- Swap `s.icon` in the 200px circle for actual artwork.
