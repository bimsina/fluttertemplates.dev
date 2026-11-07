---
title: Order Confirmation
description: Animated checkmark, order number, delivery estimate
app: core
path: /ecommerce/order_confirmation
code_files: ["ecommerce/order_confirmation.dart"]
---

## How it works

An `AnimationController` starts in `initState`, runs for 600ms and passes through `Curves.elasticOut`, so the `ScaleTransition` gives the check icon a springy entrance. `SingleTickerProviderStateMixin` supplies the vsync, and `dispose` releases the controller. `_estimatedDelivery` is five days after the screen opens, formatted by `_formatDate`. The order number is hardcoded, and Continue Shopping calls `onContinueShopping`, or shows a demo `SnackBar` without it.

## Adapting it

- Add constructor parameters to `OrderConfirmation` for the order id and delivery date, replacing the literal order number and `_estimatedDelivery`.
- In `onContinueShopping`, pop back to your home route so the back button cannot return to checkout.
- Shorten `duration` or swap the curve on `_scaleAnim` to tone the bounce down.
