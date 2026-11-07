---
title: Destination Cards
description: A showcase of Flutter's destination cards functionality
app: core
path: /travel/destination_cards
code_files: ["travel/destination_cards.dart"]
---

## How it works

`_destinations.asMap()` gives each `Card` an index for its tint, safely wrapped by `i % Colors.primaries.length`. A 160px colored block stands in for a photo, with name and country opposite price and rating. `price` is a preformatted string, so it can't be sorted numerically. The `InkWell`'s `onTap` shows a demo `SnackBar`.

## Adapting it

- Replace the colored `Container` with `Image.network`, and set `clipBehavior` on `Card`.
- Store `price` as a number, formatting it with `intl`.
- Push a detail page from `onTap`, using `Hero` on the image.
