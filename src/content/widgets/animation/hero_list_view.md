---
title: "Hero List"
description: "A beautiful list view with hero animations for smooth transitions between list items and detail views. Perfect for showcasing content with engaging animations."
code_files: ["animation/hero_list_view.dart"]
path: "/animation/hero_list_view"
order: 1
icon: mdi:view-list
---

## How it works

Both screens wrap a `Container` in a `Hero` with the same tag, `hero_list_item_$index`, and pushing a `MaterialPageRoute` triggers the flight from the 60 px wide thumbnail to the 250 px tall banner. `HeroListItemPage` receives only an `index` and reads the top-level `items` list, so the two screens are tied to that global. `_HeroListViewState` holds no state.

## Adapting it

- Pass an `Item` to `HeroListItemPage` instead of `index`, which removes the dependency on `items`.
- Build the `Hero` tag from a stable id once data is dynamic, because index-based tags break if the list reorders between push and pop.
- Extend `Item` beyond `title`, `icon` and `color`, then lay the new fields out under the banner.
