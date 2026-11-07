---
title: Value Prop Onboarding
description: A Flutter onboarding value-proposition screen with benefit rows and a get-started button.
app: core
path: /must_haves/onboarding_page/value_prop
code_files: ["must_haves/onboarding_page/value_prop.dart"]
---

## How it works

A single stateless screen, no paging. A `for` loop over `_benefits` emits an icon-and-text row per `_Benefit`, then a `Spacer` pushes the two buttons to the bottom. Since the whole thing is a plain `Column`, large text settings or short phones will overflow instead of scrolling. Both buttons show a demo `SnackBar`.

## Adapting it

- Edit `_benefits` and the headline strings; the finance copy is sample text.
- Route `Get started` to sign-up and the `TextButton` to sign-in.
- For small devices, put the list in an `Expanded` scrollable and keep the buttons outside it.
