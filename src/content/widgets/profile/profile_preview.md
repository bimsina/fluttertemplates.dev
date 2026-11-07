---
title: Profile Preview
description: Public profile view with stats, posts grid, and follow buttons
app: core
path: /profile/profile_preview
code_files: ["profile/profile_preview.dart"]
---

## How it works

`CustomScrollView` with a 280px `SliverAppBar` whose gradient background hosts the avatar, name and handle, inside a `FittedBox` that shrinks them to fit large text. The rest is one `SliverToBoxAdapter`. The location line is a `Wrap`, and stats share the row through `Expanded`. `_buildTabItem` only imitates tabs, so `Posts` stays selected. `Follow` toggles `_following`. `_buildContentGrid` shows nine gradient tiles in a `shrinkWrap` grid that builds every item at once.

## Adapting it

- For long feeds, move the grid out to a `SliverGrid` so tiles load lazily.
- Replace `_buildTabItem` with `TabBar`, or track the selected tab in state.
- Take a user model, and theme the fixed greys in `_buildStat` and `_buildDivider`.
