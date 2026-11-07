---
title: App Bar Variants
description: A Flutter gallery of app bar variants — with search, actions, gradients, and a bottom tab bar.
app: core
path: /navigation/app_bar_variants
code_files: ["navigation/app_bar_variants.dart"]
---

## How it works

A style gallery rather than working bars: none of the four samples is an `AppBar`. Each is a `Container` holding a `Row` of plain `Icon`s and `Text`, so nothing responds to taps. `_bar` supplies the shared 64px surface, `_label` the section captions, and `_tab` fakes a tab strip with a colored bottom border. The search field is static too.

## Adapting it

- Move the layout you like into a real `AppBar`, turning each `Icon` into an `IconButton`.
- For the gradient look, set `flexibleSpace` on `AppBar` to the `LinearGradient` container.
- Replace `_tab` with `TabBar` when you need working tabs.
