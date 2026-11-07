---
title: Listing Detail
description: A Flutter marketplace listing detail with an image gallery, seller card, and a buy button.
app: core
path: /marketplace/listing_detail
code_files: ["marketplace/listing_detail.dart"]
---

## How it works

The gallery is a `PageView` over `_colors`, with `_page` updated from `onPageChanged` to light up the dot row layered on top by a `Stack`. Those "photos" are tinted `Icons.chair` placeholders. `Message` and `Buy now` sit in Scaffold's `bottomSheet`, and a `SizedBox(height: 90)` at the end of the `ListView` keeps the description clear of them. The heart toggles `_favorite`, and listing and seller text are literals.

## Adapting it

- Pass in a listing model and replace `_colors` with image URLs.
- Connect `Buy now` to checkout and `Message` to your chat flow.
- If the `bottomSheet` height changes, update that 90px spacer to match.
