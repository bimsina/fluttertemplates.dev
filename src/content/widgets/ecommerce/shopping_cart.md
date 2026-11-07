---
title: Shopping Cart
description: Cart items with quantity stepper, swipe to dismiss, running total
app: core
path: /ecommerce/shopping_cart
code_files: ["ecommerce/shopping_cart.dart"]
---

## How it works

`_total` folds over `items` for a running sum, and `Dismissible` provides swipe-to-delete on a red background. `items` copies every map out of the const `_items`, because `item['qty']++` would otherwise throw on an unmodifiable map. The stepper stops at 1, so only a swipe removes a line.

## Adapting it

- `Key` and `removeWhere` both rely on `title`, so duplicate titles will misbehave; use a product id.
- Pass `onCheckout`, which receives each `CartLine` and the total. Without it, Checkout shows a demo `SnackBar`.
- Checkout disables when `items` runs out, so add an empty state, since the list goes blank.
