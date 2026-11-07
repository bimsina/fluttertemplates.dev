---
title: Seller Profile
description: A Flutter marketplace seller profile with ratings, stats, and a grid of items.
app: core
path: /marketplace/seller_profile
code_files: ["marketplace/seller_profile.dart"]
---

## How it works

A `ListView` with a `Wrap` header, three stats built by `_stat`, and a three-column grid. `_items` is a const list of records, unpacked with a `for (final (icon, price, color) in _items)` pattern. The grid uses `shrinkWrap` and `NeverScrollableScrollPhysics` so it scrolls with the page. `Follow` toggles `_following`, which also moves the `Followers` count. Other stats are literals, which is why `Listings` says 12 while six tiles appear.

## Adapting it

- Load a seller model and compute the counts passed to `_stat` from it.
- Send `_following` to your API from the `Follow` button.
- Give `_items` real image URLs, and wrap each tile in an `InkWell` that opens the listing.
