---
title: Place Detail
description: A Flutter place detail sheet with photos, rating, hours, and directions and call actions.
app: core
path: /maps/place_detail
code_files: ["maps/place_detail.dart"]
---

## How it works

`CustomScrollView` pairs a pinned `SliverAppBar` with a single `SliverToBoxAdapter` that holds the details. The header is a gradient built from `scheme.tertiary` and `scheme.primary` with a faint icon, and the photo strip is five gray boxes from a horizontal `ListView.separated`. Everything about `Blue Fig Bistro` is hardcoded in the build method, and the buttons show a demo `SnackBar` through `_showDemo`.

## Adapting it

- Accept a place model through the `PlaceDetail` constructor and bind name, rating and hours to it.
- Use real images in `FlexibleSpaceBar` and replace `itemCount: 5`.
- Wrap the long `Text` in the rating `Row` with `Expanded`, since longer strings will overflow.
