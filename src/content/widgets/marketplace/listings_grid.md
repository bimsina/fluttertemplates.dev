---
title: Listings Grid
description: A Flutter marketplace listings grid with category filters, prices, and favourite buttons.
app: core
path: /marketplace/listings_grid
code_files: ["marketplace/listings_grid.dart"]
---

## How it works

Seven const `_Listing` items fill a two-column `GridView.count`. Each has a `category`, and `_visibleItems` filters them by the selected `ChoiceChip`, with `All` showing everything. Favorites work too: `_faved` holds listing titles toggled by the heart button, so they survive filtering, starting with `Road bike` selected. The search button shows a demo `SnackBar`, and cards aren't tappable.

## Adapting it

- Key `_faved` by listing ID, because titles can repeat in real data.
- Fetch `_items` from your API, and call it again when `_filter` changes if filtering is server-side.
- Show an empty state when a category has no items.
