---
heroImage: "../../assets/template_images/food-delivery.png"
title: "Food Delivery App"
description: "Flutter food delivery app template with restaurant list and category filter, menus, item customization, cart with live totals and promo codes, validated checkout, animated order tracking on a CustomPaint map, and order history. Flutter SDK only, ChangeNotifier state, light and dark themes, responsive from phone to tablet."
summary: "Browse restaurants, customize items, check out and track the order on a map."
type: full-app
path: /templates/food_delivery
code_dir: templates/food_delivery
tags:
  [
    "food delivery",
    "restaurant",
    "ecommerce",
    "cart",
    "checkout",
    "order tracking",
    "changenotifier",
    "custompaint",
    "material 3",
    "responsive",
  ]
---

## What's included

A complete ordering flow that runs on in-memory data, with no packages beyond the Flutter SDK and no image assets.

- **Home:** restaurant list, category filter, search across restaurants and dishes, loading and empty states, and a live banner for an order in progress.
- **Restaurant menu:** collapsing header, section chips that follow the scroll position, and a cart bar that appears once something is added.
- **Item customization:** required and optional option groups, selection limits, a note for the kitchen, and a price that updates as you choose. Tapping a cart line reopens this screen to edit it.
- **Cart:** quantity steppers, swipe to remove with undo, promo codes, a minimum order check, and live totals. A cart holds one restaurant at a time, and adding from another asks first.
- **Checkout:** validated address and card forms, delivery time, payment method, and tip. The form scrolls to the first error, and the address is remembered for the next order.
- **Order tracking:** an animated courier on a map, status steps, and a countdown. Tracking keeps running while you browse other screens. If the live updates stop, the order keeps its last status, and the tracking and orders screens say so and offer Retry.
- **Order history:** active and past orders, receipts, and reorder.

Each restaurant has a seed color. The menu, cart, checkout and tracking screens generate their color scheme from it with `ColorScheme.fromSeed`, and dishes are drawn with `CustomPaint` from that scheme. All colors come from the scheme, so light and dark mode both work without extra code. On wide screens the bottom bar becomes a navigation rail, and the home, menu, checkout and tracking screens switch to multi-column layouts.

## Structure

```text
food_delivery/
  app.dart      FoodDeliveryApp, the root widget with its own Navigator
  models/       Restaurant, MenuItem, CartLine, Order and formatting helpers
  data/         FoodRepository interface, the swap point, in-memory implementation, fake data
  state/        CartController, OrdersController and the InheritedNotifier scopes
  screens/      One file per screen
  widgets/      Theme, dish art, receipt, route map and shared components
```

All imports are relative, so you can copy the folder into any project. `FoodDeliveryApp` needs a `MaterialApp` above it and follows that app's brightness.

```dart
MaterialApp(home: const FoodDeliveryApp());
```

Pass `seedColor` to change the color of the screens that don't belong to a restaurant. Restaurant colors are set in `data/fake_data.dart`.

## Connecting a real backend

The UI only talks to the `FoodRepository` interface in `data/food_repository.dart`, and `data/default_repository.dart` is the only file that names the in-memory version. To use your own API:

1. Create a class that implements `FoodRepository`, using any HTTP client.
2. Return it from `data/default_repository.dart`, in place of the in-memory one:

```dart
import 'api_food_repository.dart';
import 'food_repository.dart';

FoodRepository createDefaultRepository() =>
    ApiFoodRepository(baseUrl: '...');
```

3. Delete `data/in_memory_food_repository.dart` and `data/fake_data.dart`.

`FoodDeliveryApp(repository: ...)` overrides the default for one app instance, which is useful in tests. It doesn't replace step 2.

A few things to handle when you do:

- **Restaurant seed colors and dish art:** `Restaurant.seedColor` and `DishKind` are not usually in an API response. Map them from your own data, or replace `DishArt` with your images.
- **Live tracking:** `watchOrder` returns a stream of `TrackingUpdate`, which fits a WebSocket or server-sent events. `OrdersController` subscribes when an order is placed. An error, or the stream closing before the delivered event, sets `hasError` and `hasTrackingError(orderId)` until the stream emits again, and Retry calls `watchOrder` once more, so emit the current status first on each listen. Orders that are already in progress when the app starts are not re-subscribed, so add that in `OrdersController.load` if you need it.
- **The map:** `RouteMap` draws a fixed route from a 0 to 1 progress value. Replace it with a map SDK and courier coordinates.
- **Payments:** the card form only validates its fields, and the card details are never stored or sent. Use your payment provider's SDK and pass its token in `OrderDraft`.
- **Prices:** `CartController` calculates fees and tax on the device so the totals can update instantly. Treat those as estimates, and have the server calculate the amount it charges.
- **Scheduled orders:** `OrderDraft.scheduledFor` is a display label, so send a real timestamp to your API.
- **Placing an order:** `placeOrder` has no idempotency key or timeout. If the response to a real order is lost, checkout says it failed and trying again places a second one, so add a key to `OrderDraft` and honor it on the server.
