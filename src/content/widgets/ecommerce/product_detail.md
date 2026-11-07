---
title: Product Detail
description: Collapsing image header, size/color selectors, sticky Add to Cart bar
app: core
path: /ecommerce/product_detail
code_files: ["ecommerce/product_detail.dart"]
---

## How it works

A `CustomScrollView` pairs a collapsing 300px `SliverAppBar` with two groups of `ChoiceChip`s. `_size` holds the chosen label and `_color` an index into `Colors.primaries`. Name, price and image are placeholders. With no `onAddToCart`, the button in `bottomNavigationBar` counts in `_inCart` and shows a demo `SnackBar`. With one, the host owns the cart: the selection goes to the callback, and the badge shows `cartCount`, staying hidden if that's omitted.

## Adapting it

- Give `ProductDetail` a product parameter and use its variants in place of the `['S', 'M', 'L', 'XL']` list.
- Replace the tinted `Container` in `FlexibleSpaceBar` with your product photo.
- Call your cart service from `onAddToCart`, and pass its size as `cartCount`.
