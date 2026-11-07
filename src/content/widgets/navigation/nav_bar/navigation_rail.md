---
title: Navigation Rail
description: A Flutter NavigationRail for side navigation on tablet and desktop layouts.
app: core
path: /navigation/nav_bar/navigation_rail
code_files: ["navigation/nav_bar/navigation_rail.dart"]
previewSize: "tablet"
---

## How it works

This doubles as a playground: the content pane holds controls for every `NavigationRail` option. `_extended` needs a 600px window, as the 256px rail would crowd out the pane, so narrower windows disable the switch. An extended rail only allows `labelType` `none`, so `effectiveLabelType` forces it and `_updateLabelType` ignores input. `Badge` wraps the notification and message icons. The pane scrolls, and each `SegmentedButton` scrolls sideways when it can't fit.

## Adapting it

- Delete the controls, keeping the values you want for `groupAlignment`, `labelType` and `isExtended`.
- Fill the `Expanded` pane based on `_selectedIndex`, and feed real counts to `Badge`.
