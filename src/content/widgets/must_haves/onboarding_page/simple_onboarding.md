---
title: Simple Onboarding
description: A Flutter onboarding screen with swipeable intro slides, page dots, and a get-started button.
app: core
path: /must_haves/onboarding_page/onboarding_page_1
code_files: ["must_haves/onboarding_page/onboarding_page_1.dart"]
---

## How it works

`OnboardingPagePresenter` is reusable: it takes a list of `OnboardingPageModel` and optional `onSkip` and `onFinish` callbacks. An `AnimatedContainer` fades the background to `bgColor` as `_currentPage` changes, and the page dots animate width. The demo `OnboardingPage1` wires both callbacks to `_exit`, which only shows a `SnackBar`. `_pageController` is disposed, and images load from third-party `i.ibb.co` links, with an `errorBuilder` icon if they fail.

## Adapting it

- Replace `_exit` with navigation into your app.
- Save a "seen" flag so returning users skip the flow.
- Bundle the art and use `Image.asset` in place of `Image.network`.
