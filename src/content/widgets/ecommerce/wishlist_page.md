---
title: Wishlist
description: Grid with heart toggle, Move to Cart action
app: core
path: /ecommerce/wishlist_page
code_files: ["ecommerce/wishlist_page.dart"]
---

## How it works

`_items` is a plain field in `_WishlistPageState`, not const data, so its maps can be mutated in place. A heart `IconButton` floats over each card through `Stack` and `Positioned` and flips `hearted` with `setState`. Unhearting only changes the icon: the product stays in the grid. Move to Cart removes the item, confirms with a `SnackBar`, and reports the title through `onMoveToCart`.

## Adapting it

- Remove the entry from `_items` in the heart's `onPressed` if unhearting should delete it, ideally with an undo `SnackBar`.
- Persist each toggle to your wishlist endpoint, since `_items` only lives in memory.
