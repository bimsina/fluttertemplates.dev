---
title: Product Grid
description: Responsive grid of product cards with image placeholder, title, price, rating
app: core
path: /ecommerce/product_grid
code_files: ["ecommerce/product_grid.dart"]
---

## How it works

Six `_products` sit in a `GridView.builder` with two columns, or three once `MediaQuery` reports more than 600px, and `childAspectRatio` divides by the text scale so cells grow with large fonts. Each card uses a tinted `Container` inside `Expanded` as an image stand-in, picking from `Colors.primaries` with a modulo so the index stays in range. Title, price and rating are read from untyped maps, and cards ignore taps.

## Adapting it

- Swap the `Container` for a network image with `BoxFit.cover` once products have URLs.
- Wrap the `Card` in an `InkWell` to open a detail page.
- Fetch `_products` from your API and request more pages as `itemBuilder` nears the end of the list.
