---
title: Restaurant List
description: A showcase of Flutter's restaurant list functionality
app: core
path: /food/restaurant_list
code_files: ["food/restaurant_list.dart"]
---

## How it works

Rather than `ListTile`, every card uses a hand-built `Row`, which leaves room for an 80px thumbnail. That thumbnail is a tinted `Container` picked from `Colors.primaries` with a modulo, and the rating line is a `Wrap`, so large text breaks onto a second line. All five `_restaurants` are const maps. A `chevron_right` implies navigation, but the cards have no tap handler.

## Adapting it

- Wrap the `Card` contents in an `InkWell` and push your detail route.
- Replace the `Container` with a photo clipped to the same 12px radius.
- `delivery` is a preformatted range such as `25-35 min`; keep numeric minutes too if you want to sort by speed, and fetch `_restaurants` from your API.
