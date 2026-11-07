---
title: Hotel Listing
description: A showcase of Flutter's hotel listing functionality
app: core
path: /travel/hotel_listing
code_files: ["travel/hotel_listing.dart"]
---

## How it works

A `ListTile` pushed further than usual: an 80px `Container` as `leading`, a `Column` subtitle with location and rating, and a stacked price in `trailing`. The image is a tint from `Colors.primaries`, wrapped with a modulo for long lists. The filter button and row `onTap` show a demo `SnackBar`, and ratings and prices come straight from `_hotels`.

## Adapting it

- Swap the `Container` for a clipped `Image.network`.
- Open a filter bottom sheet from `Icons.filter_list`, and apply it to a typed hotel list.
- If rows get richer, replace `ListTile` with a custom `Row` for better height control.
