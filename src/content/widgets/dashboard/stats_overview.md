---
title: Stats Overview
description: A showcase of Flutter's stats overview functionality
app: core
path: /dashboard/stats_overview
code_files: ["dashboard/stats_overview.dart"]
---

## How it works

`GridView.builder` lays out the `_stats` tiles in two columns above 600px of screen width and one below, at two-to-one unless scaled text needs more height through `mainAxisExtent`. An entry's optional `status` sets the color of its `sub` line: `good` is green, `bad` is orange, and anything else keeps the theme default. That keeps the 15% latency drop green although its arrow points down. Values are hardcoded strings with no refresh logic.

## Adapting it

- Load `_stats` from your metrics endpoint and refresh it on a timer or pull gesture.
- Width comes from `MediaQuery`, which measures the whole screen; use `LayoutBuilder` if the grid will sit beside a sidebar.
