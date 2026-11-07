---
title: Food Cart
description: A Flutter food cart with working quantities, a delivery fee, and a checkout callback.
app: core
path: /food/food_cart
code_files: ["food/food_cart.dart"]
---

## How it works

`_FoodCartState` copies `items`, or the sample lines, into a mutable list of `FoodCartItem`. The plus and minus `IconButton`s replace a line through `_setQuantity`, and reaching zero removes it, so subtotal and total update in `build`. A fixed `_delivery` of `3.99` applies only while the cart has items. Checkout, disabled when empty, passes the lines and total to `onCheckout`, or shows a demo `SnackBar` without it.

## Adapting it

- Pass your cart lines through `items`; a new list replaces local quantities.
- Get `_delivery` from your backend, and call your order API from `onCheckout`.
