---
title: Tabbed Content
description: Scrollable tabs with custom indicator and varied content
app: core
path: /layouts/tabbed_content
code_files: ["layouts/tabbed_content.dart"]
---

## How it works

A manually managed `TabController` with `length: 4` connects a scrollable `TabBar` in the app bar's `bottom` slot to a `TabBarView`. `TabAlignment.start` keeps tabs left-aligned rather than centered. Each page is a `_ContentTab` with an icon and sentence of placeholder text, so swiping and tab taps are the only working behavior.

## Adapting it

- Replace each `_ContentTab` with the real screen for that tab.
- Keep `length` equal to the number of `Tab`s and `TabBarView` children; a mismatch throws.
- If you never need to change tabs from code, `DefaultTabController` removes `initState`, `dispose` and the mixin.
