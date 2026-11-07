---
title: Product List
description: Vertical list with thumbnail placeholder, title, price, Add to Cart
app: core
path: /ecommerce/product_list
code_files: ["ecommerce/product_list.dart"]
---

## How it works

Three `_products` render as `ListTile`s inside `Card`s: a 60px tinted square, title and price, and a trailing Add to Cart button. `ListView.builder` keeps the list lazy. With no `onAddToCart`, the button counts in `_inCart` and shows a demo `SnackBar`. With one, the host owns the cart: the title goes to the callback, and the badge shows `cartCount`, staying hidden if that's omitted. There's no real image.

## Adapting it

- Call your cart logic from `onAddToCart`, and pass the cart's size as `cartCount`.
- Put a real thumbnail in `leading` in place of the tinted `Container`.
- `price` is a display string; store a number so carts can do math on it.
