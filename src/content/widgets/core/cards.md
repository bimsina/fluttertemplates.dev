---
title: Cards
description: A Flutter cards gallery with elevated, outlined, gradient, and interactive card styles.
app: core
path: /core/cards
code_files: ["core/cards.dart"]
---

## How it works

Four variants sit in one stateless `ListView`, separated by `_label` headers. Elevated and outlined are `Card`s with different `elevation` and `shape`. The gradient one is actually a `Container`, so `CardTheme` won't reach it and its white text is set by hand. The interactive card uses `Clip.antiAlias` to keep the `InkWell` ripple inside the corners, and its `onTap` shows a demo `SnackBar`.

## Adapting it

- Lift a `Card` variant into its own widget with title and subtitle parameters before reusing it.
- Check `Colors.white` text against `scheme.primary` and `scheme.tertiary` in your theme, since it won't adapt.
- Replace the `Icons.image` placeholder with `Image.network`, and put navigation in `onTap`.
